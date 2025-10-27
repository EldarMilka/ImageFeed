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
                print("[fetchProfile]: Ошибка базового профиля - \(error)")
                fetchError = error
            }
            group.leave()
        }
        
        // Запрос 2: GET /users/:username - аватарка (после получения username)
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            if let error = fetchError {
                print("[fetchProfile]: Общая ошибка - \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let profileResult else {
                print("[fetchProfile]: NetworkError - отсутствуют данные профиля")
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
                    print("[fetchProfile]: Ошибка загрузки аватарки - \(error), username: \(profileResult.username)")
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
            print("[fetchBasicProfile]: NetworkError - неверный запрос")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        profileTask = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error> ) in
            switch result {
            case .success(let profileResult):
                completion(.success(profileResult))
            case .failure(let error):
                print("[fetchBasicProfile]: \(error)")
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
            print("[fetchProfileImage]: NetworkError - неверный запрос для username: \(username)")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        imageTask = urlSession.objectTask(for: request) { (result: Result<ProfileImageResult, Error>) in
            switch result {
            case .success(let imageResult):
                completion(.success(imageResult))
            case .failure(let error):
                print("[fetchProfileImage]: \(error) - username: \(username)")
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
