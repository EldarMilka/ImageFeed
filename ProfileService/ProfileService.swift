//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 25.08.2025.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()

    private var profileTask: URLSessionTask?
    private var imageTask: URLSessionTask?

    private(set) var profile: Profile?

    private let urlSession = URLSession.shared

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        // Отменяем предыдущие задачи
        profileTask?.cancel()
        imageTask?.cancel()

        // Создаем группу для ожидания двух запросов
        let group = DispatchGroup()
        var profileResult: ProfileResult?
        var profileImageResult: ProfileImageResult?
        var fetchError: Error?

        // Запрос 1: GET /me - базовая информация
        group.enter()
        fetchBasicProfile(token: token) { result in
            switch result {
            case .success(let result):
                profileResult = result
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }

        // Запрос 2: GET /users/:username - аватарка (после получения username)
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }

            if let error = fetchError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let profileResult else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError)) // 2
                }
                return
            }

            // Теперь делаем второй запрос для аватарки
            group.enter()
            fetchProfileImage(username: profileResult.username, token: token) { result in
                switch result {
                case .success(let imageResult):
                    profileImageResult = imageResult
                case .failure(let error):
                    print("Ошибка загрузки аватарки: \(error)")
                }
                group.leave()
            }

            group.notify(queue: .main) {
                let profile = Profile(from: profileResult, profileImageResult)

                self.profile = profile

                DispatchQueue.main.async {
                    completion(.success(profile))
                }
            }
        }
    }

    // MARK: - Private Methods

    private func fetchBasicProfile(token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        profileTask = urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    completion(.success(profileResult))
                } catch {
                    print("Ошибка декодирования профиля: \(error)")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("Ошибка сети: \(error)")
                completion(.failure(error))
            }
        }

        profileTask?.resume()
    }

    private func fetchProfileImage(
        username: String,
        token: String,
        completion: @escaping (Result<ProfileImageResult, Error>) -> Void
    ) {
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        imageTask = urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let imageResult = try JSONDecoder().decode(ProfileImageResult.self, from: data)
                    completion(.success(imageResult))
                } catch {
                    print("Ошибка декодирования аватарки: \(error)")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("Ошибка сети при загрузке аватарки: \(error)")
                completion(.failure(error))
            }
        }

        imageTask?.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
