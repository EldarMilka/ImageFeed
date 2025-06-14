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
                } catch {
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
    let scope: String
    let createdAt: Int
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
    }
