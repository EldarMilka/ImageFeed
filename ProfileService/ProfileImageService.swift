////
////  ProfileImageService.swift
////  ImageFeed
////
////  Created by Эльдар Милкаманавичюс on 09.09.2025.
////
 import Foundation
    
final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService(); private init() {}
    
    private(set) var avatarURL: String?
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
     func fetchProfileImageUrl(username: String, completion: @escaping  (Result<String, Error>) -> Void){
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            print("[fetchProfileImageUrl]: AuthError - отсутствует токен для username: \(username)")
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[fetchProfileImageUrl]: URLError - неверный URL для username: \(username)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
         let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileImageResult, Error>) in
             guard let self = self else { return }
             
             switch result {
             case .success(let userResult):
                 let avatarURL = userResult.profileImage.small
                 self.avatarURL = avatarURL
                 
                 NotificationCenter.default
                     .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                     )
                 completion(.success(avatarURL))
             case .failure(let error):
                 print("[fetchProfileImageUrl]: \(error) - username: \(username)")
                 completion(.failure(error))
             }
         }
    
        self.task = task
        task.resume()
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
    
    func clean() {
        avatarURL = nil
    }
    }
    










