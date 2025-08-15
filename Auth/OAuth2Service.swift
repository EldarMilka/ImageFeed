//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 10.06.2025.
//

import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {

    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private var completions: [(Result<String, Error>) -> Void] = []
    private init() {}

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        if let lastCode = lastCode, lastCode == code {
                    completions.append(completion)
                    return
                }
        
        if task != nil {
                    completions.forEach { $0(.failure(AuthServiceError.invalidRequest)) }
                    completions.removeAll()
                    task?.cancel()
                    task = nil
                }
        
        lastCode = code
                completions.append(completion)
        
//        if task != nil {
//            if lastCode != code {
//                task?.cancel()
//            } else {
//                completion(.failure(AuthServiceError.invalidRequest))
//                return
//            }
//        } else {
//            if lastCode == code {
//                completion(.failure(AuthServiceError.invalidRequest))
//                return
//            }
//        }
//        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completeALL(with: .failure(AuthServiceError.invalidRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                defer {
                    self?.task = nil
                    self?.lastCode = nil
                }

                if let error = error {
                    self?.completeALL(with: .failure(error))
                    return
                }

                guard let data = data else {
                    self?.completeALL(with: .failure(AuthServiceError.invalidRequest))
                    return
                }

                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
                    self?.completeALL(with: .success(tokenResponse.accessToken))
                } catch {
                    print("❌ Ошибка декодирования токена: \(error.localizedDescription)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📦 Ответ сервера:\n\(jsonString)")
                    }
                    self?.completeALL(with: .failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }

    private func completeALL(with result: Result<String, Error>) {
        completions.forEach{ $0(result)}
        completions.removeAll()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("❌ Ошибка: невозможно создать URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams = [
            "client_id": Constants.AccessKey,
            "client_secret": Constants.SecretKey,
            "redirect_uri": Constants.RedirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        let bodyString = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)
        return request
    }
}

struct OAuthTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String?
    let scope: String
    let createdAt: Int
    let userId: Int?
    let username: String?

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
        case userId = "user_id"
        case username
    }
}
