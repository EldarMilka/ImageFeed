//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 10.06.2025.
//

import UIKit
final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private init() {}

    func makeOAuthTokenRequest(code: String) -> URLRequest {
        let url = URL(string: "https://unsplash.com/oauth/token")!
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

    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(tokenResponse.accessToken))
                    }
                } catch { print("❌ Ошибка декодирования токена: \(error.localizedDescription)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📦 Ответ сервера:\n\(jsonString)")
                    }
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
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

