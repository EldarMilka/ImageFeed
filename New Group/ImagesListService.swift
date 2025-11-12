//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 06.09.2025.
//

import Foundation
import CoreGraphics

// MARK: - Protocol
protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - Service Implementation
final class ImagesListService: ImagesListServiceProtocol {
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
        guard currentTask == nil else {
            print("⚠️ ImagesListService: Задача уже выполняется")
            return
        }
        
        guard let token = oauth2TokenStorage.token else {
            print("❌ ImagesListService: нет токена")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        print("🟢 ImagesListService: Загружаем страницу \(nextPage)")
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else {
            print("❌ ImagesListService: Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        currentTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.currentTask = nil }
            
            if let error = error {
                print("❌ ImagesListService: Ошибка загрузки: \(error)")
                return
            }
            
            guard let data = data else {
                print("❌ ImagesListService: Нет данных")
                return
            }
            
            // Дополнительная отладка
            if let httpResponse = response as? HTTPURLResponse {
                print("🟢 ImagesListService: HTTP статус: \(httpResponse.statusCode)")
            }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                print("🟢 ImagesListService: Получено \(photoResults.count) фото")
                
                let newPhotos = photoResults.map { self.convert(photoResult: $0) }
                
                DispatchQueue.main.async {
                    self.lastLoadedPage = nextPage
                    let existingIds = Set(self.photos.map { $0.id })
                    let uniqueNewPhotos = newPhotos.filter { !existingIds.contains($0.id) }
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    
                    print("🟢 ImagesListService: Всего фото теперь: \(self.photos.count)")
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self)
                }
            } catch {
                print("❌ ImagesListService: Ошибка декодирования: \(error)")
                // Выведем сырые данные для отладки
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Сырой ответ: \(String(describing: jsonString.prefix(500)))")
                }
            }
        }
        currentTask?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "/photos/\(photoId)/like"
        let httpMethod = isLike ? "POST" : "DELETE"
        
        print("🟡 ChangeLike: photoId=\(photoId), isLike=\(isLike), method=\(httpMethod)")
        
        guard let url = URL(string: "https://api.unsplash.com\(endpoint)") else {
            print("❌ ChangeLike: Неверный URL для endpoint: \(endpoint)")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        guard let token = oauth2TokenStorage.token else {
            print("❌ ChangeLike: Нет токена")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("🟡 ChangeLike: Токен есть, длина: \(token.count) символов")
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            // Логируем ответ
            if let error = error {
                print("❌ ChangeLike: Ошибка сети: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ ChangeLike: Некорректный ответ")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            print("📡 ChangeLike: HTTP статус: \(httpResponse.statusCode)")
            
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                print("📄 ChangeLike: Тело ответа: \(responseBody)")
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                print("🟢 ChangeLike: Успех! Обновляем состояние фото")
                DispatchQueue.main.async {
                    // Находим и обновляем фото
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        print("🟢 ChangeLike: Найдено фото с index \(index), обновляем isLiked с \(self.photos[index].isLiked) на \(isLike)")
                        var photo = self.photos[index]
                        photo.isLiked = isLike
                        self.photos[index] = photo
                        
                        // Отправляем уведомление об изменении
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["changedPhotoId": photoId]
                        )
                        completion(.success(()))
                    } else {
                        print("❌ ChangeLike: Фото с id \(photoId) не найдено в массиве")
                        completion(.failure(NetworkError.urlSessionError))
                    }
                }
            } else {
                print("❌ ChangeLike: Ошибка HTTP: статус \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
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
