//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 06.09.2025.
//

import Foundation
import CoreGraphics

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let perPage: Int = 10
    private let urlSession = URLSession.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        guard currentTask == nil else { return }
        guard let token = oauth2TokenStorage.token else {
            print("❌ ImagesListService: нет токена")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else {
            print("❌ Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        currentTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.currentTask = nil }
            
            if let error = error {
                print("❌ Ошибка загрузки: \(error)")
                return
            }
            
            guard let data = data else {
                print("❌ Нет данных")
                return
            }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { self.convert(photoResult: $0) }
                
                DispatchQueue.main.async {
                    self.lastLoadedPage = nextPage
                    let existingIds = Set(self.photos.map { $0.id })
                    let uniqueNewPhotos = newPhotos.filter { !existingIds.contains($0.id) }
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self)
                }
            } catch {
                print("❌ Ошибка декодирования: \(error)")
            }
        }
        currentTask?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "/photos/\(photoId)/like"
        let httpMethod = isLike ? "POST" : "DELETE"
        
        guard let url = URL(string: "https://api.unsplash.com\(endpoint)") else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        guard let token = oauth2TokenStorage.token else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        var photo = self.photos[index]
                        photo.isLiked = isLike
                        self.photos[index] = photo
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self)
                    }
                    completion(.success(()))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode((response as? HTTPURLResponse)?.statusCode ?? -1)))
                }
            }
        }
        task.resume()
    }
    
    private func convert(photoResult: PhotoResult) -> Photo {
        let createdAt = photoResult.createdAt.flatMap { iso8601DateFormatter.date(from: $0) }
        return Photo(
            id: photoResult.id ?? "",
            size: CGSize(width: photoResult.width ?? 0, height: photoResult.height ?? 0),
            createdAt: createdAt,
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb ?? "",
            largeImageURL: photoResult.urls.regular ?? "",
            fullImageUrl: photoResult.urls.full ?? "",
            isLiked: photoResult.likedByUser ?? false
        )
    }
    
    func clean() {
        photos = []
        lastLoadedPage = nil
        currentTask?.cancel()
        currentTask = nil
    }
}
