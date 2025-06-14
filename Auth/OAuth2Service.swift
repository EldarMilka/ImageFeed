//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 10.06.2025.
//

import UIKit

    final class OAuth2Service {
//        private let tokenURL = URL(string: "https://example.com/oauth/token")!

        static let shared = OAuth2Service()
        
        private init() {}

        
        func makeOAuthTokenRequest(code: String) -> URLRequest {
            var urlComponents = URLComponents(string: "https://unsplash.com")
            urlComponents?.path = "/oauth/token"
            urlComponents?.queryItems = [
                URLQueryItem(name: "client_id", value: "\(Constants.AccessKey)"),
                URLQueryItem(name: "client_secret", value: "\(Constants.SecretKey)"),
                URLQueryItem(name: "redirect_uri", value: "\(Constants.RedirectURI)"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                ]
            
            guard let url = urlComponents?.url else {
                fatalError("Ошибка OAuth token")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            return request
        }

        func fetchOAuthToken(code: String, completion: @escaping (Result<OAuthTokenResponse, Error>) -> Void) {
                let request = makeOAuthTokenRequest(code: code)
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("❌ Сетевая ошибка: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    
                    guard let data else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных"])))
                        }
                        return
                    }

                    do {
                        let tokenResponse = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(tokenResponse))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                task.resume()
            }
        }

struct OAuthTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
        let token_type: String
        let scope: String
        let created_at: Int
    }
