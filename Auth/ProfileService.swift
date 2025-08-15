//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 19.06.2025.
//

import Foundation


struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}


struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

enum ProfileServiceError: Error {
    case emptyData
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private var task: URLSessionTask?
    private(set) var profile: Profile?

 
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)

   
        task?.cancel()

        let request = makeProfileRequest(token: token)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.task = nil

                if let error = error {
                    print("❌ Ошибка запроса профиля: \(error)")
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    print("❌ Пустой ответ при получении профиля")
                    completion(.failure(ProfileServiceError.emptyData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = self?.convert(result: result)
                    self?.profile = profile
                    if let profile = profile {
                        completion(.success(profile))
                    }
                } catch {
                    print("❌ Ошибка декодирования профиля: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📦 Ответ сервера:\n\(jsonString)")
                    }
                    completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }

    
    private func makeProfileRequest(token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/me")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }


    private func convert(result: ProfileResult) -> Profile {
        let name = [result.firstName, result.lastName].compactMap { $0 }.joined(separator: " ")
        return Profile(
            username: result.username,
            name: name,
            loginName: "@\(result.username)",
            bio: result.bio
        )
    }
}
