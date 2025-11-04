//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 06.09.2025.
//
import Foundation
import CoreGraphics

public final class ImagesListService {
    public  private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var perPage: Int = 10
<<<<<<< HEAD
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private init() {}
    
    func fetchPhotosNextPage() {
        print("🟡🟡🟡 ImagesListService: fetchPhotosNextPage ВЫЗВАН")
        
        guard currentTask == nil else {
            print("❌ ImagesListService: Задача уже выполняется, ПРОПУСКАЕМ")
            return
        }
        
        // ✅ ПРОВЕРЬ OAuth ТОКЕН
        guard let token = oauth2TokenStorage.token else {
            print("❌❌❌ ImagesListService: OAuth токен не найден!")
            return
        }
        
        print("🟡 ImagesListService: Используем OAuth токен - \(token.prefix(10))...")
=======
    private var isLoading: Bool = false
    private var networkService: NetworkServiceProtocol
    //    private var currentTask: URLSessionTask?
    //    private let urlSession = URLSession.shared
    public static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    // public  static let shared = ImagesListService(); private init(){}
    
    public init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    public  func fetchPhotosNextPage() {
        print("🟡 Начинаем загрузку страницы...")
        //если идет закачка то прерываем
        guard !isLoading else { print("🔴 Уже идет загрузка, прерываем")
            return }
        isLoading = true
>>>>>>> origin/main
        
        let nextPage = (lastLoadedPage ?? 0) + 1
<<<<<<< HEAD
        print("🟡 ImagesListService: Загружаем страницу \(nextPage)")
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else {
            print("❌ ImagesListService: Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        // ✅ ИСПРАВЛЕНИЕ: Используем OAuth токен вместо AccessKey
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🟡 ImagesListService: URL - \(url)")
        print("🟡 ImagesListService: Используем токен пользователя")
=======
        print("🟡 Загружаем страницу: \(nextPage)")
        
>>>>>>> origin/main
        
        // guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else
        // guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos?_page=1&_limit=1") else
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else {
            isLoading = false
            print("🔴 Неверный URL")
            return
        }
        print("🟡 URL: \(url)")
        
        networkService.fetchData(from: url) { [weak self] result in
            guard let self = self else { return }
<<<<<<< HEAD
            
            defer {
                self.currentTask = nil
                print("🟡 ImagesListService: Задача ЗАВЕРШЕНА")
            }
            
            print("🟡 ImagesListService: Получили ответ от сервера")
            
            if let error = error {
                print("❌ ImagesListService: Ошибка загрузки - \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🟡 ImagesListService: Статус ответа - \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❌ ImagesListService: HTTP ошибка - \(httpResponse.statusCode)")
                }
            }
            
            guard let data = data else {
                print("❌ ImagesListService: Нет данных в ответе")
                return
            }
            
            print("🟡 ImagesListService: Получено \(data.count) байт данных")
            if let responseString = String(data: data, encoding: .utf8)?.prefix(300) {
                print("🟡 ImagesListService: Ответ: \(responseString)")
            }
            
            // В ImagesListService.swift в методе fetchPhotosNextPage
            do {
                let photosResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                print("✅✅✅ ImagesListService: УСПЕШНО декодировано \(photosResults.count) фото")
                
                let newPhotos = photosResults.map { self.convert(photoResult: $0)}
                
                DispatchQueue.main.async {
                    self.lastLoadedPage = nextPage
                    
                    // ✅ ФИЛЬТРУЕМ ДУБЛИКАТЫ
                    let existingIds = Set(self.photos.map { $0.id })
                    let uniqueNewPhotos = newPhotos.filter { !existingIds.contains($0.id) }
                    
                    if uniqueNewPhotos.count != newPhotos.count {
                        print("❌ ImagesListService: Отфильтровали \(newPhotos.count - uniqueNewPhotos.count) дубликатов")
                    }
                    
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    
                    print("✅ ImagesListService: Добавлено \(uniqueNewPhotos.count) фото. Всего: \(self.photos.count)")
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self)
                    
                    print("✅ ImagesListService: Нотификация отправлена")
                }
            } catch {
                print("❌ ImagesListService: Ошибка декодирования - \(error)")
            }
        }
        currentTask?.resume()
        print("🟡 ImagesListService: Задача ЗАПУЩЕНА")
=======
            self.isLoading = false
            switch result {
            case .success(let data ):
                do {
                    let photosResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                    let newPhotos = photosResults.map { self.convert(photoResult: $0)}
                    
                    DispatchQueue.main.async {
                        self.lastLoadedPage = nextPage
                        self.photos.append(contentsOf: newPhotos) // Новые фото добавляются в конец массива
                        
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self)
                    }
                    
                } catch {
                    print("Ошибка декодирования  \(error)")
                }
            case .failure(let error):
                print("🔴 Ошибка: \(error)")
            }
        }
>>>>>>> origin/main
    }
    
    
    //лайки
    func changeLike(photoId: String, isLike:Bool, _ completion: @escaping (Result<Void, Error>) -> Void ) {
        print("🟡 ImagesListService: Меняем лайк - photoId: \(photoId), isLike: \(isLike)")
        
        let endpoint = "/photos/\(photoId)/like"
        let httpMethod = isLike ? "POST" : "DELETE"
        
        guard let url = URL(string: "https://api.unsplash.com\(endpoint)") else {
            print("❌ ImagesListService: Неверный URL для лайка")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        guard let token = oauth2TokenStorage.token else {
            print("❌ ImagesListService: OAuth токен не найден")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🟡 ImagesListService: Отправляем \(httpMethod) запрос на \(url)")
        
        let task = urlSession.dataTask(with: request) { data , responce, error in
            if let error = error{
                print("❌ ImagesListService: Ошибка сети - \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let httpResponse = responce as? HTTPURLResponse {
                print("🟡 ImagesListService: Статус ответа - \(httpResponse.statusCode)")
                
                if 200..<300 ~= httpResponse.statusCode {
                    print("✅ ImagesListService: Лайк успешно \(isLike ? "поставлен" : "удален")")
                    DispatchQueue.main.async {
                        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                            // Создаем копию фото с обновленным состоянием лайка
                            var updatedPhoto = self.photos[index]
                            updatedPhoto.isLiked = isLike
                            self.photos[index] = updatedPhoto
                            
                            // Отправляем нотификацию об изменении
                            NotificationCenter.default.post(
                                name: ImagesListService.didChangeNotification,
                                object: self
                            )
                        }
                        completion(.success(()))
                    }
                }else {
                    print("❌ ImagesListService: HTTP ошибка - \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    }
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
    
<<<<<<< HEAD
    func clean() {
=======
    // Дополнительные методы для очистки (опционально)
   public func clean() {
>>>>>>> origin/main
        photos = []
        lastLoadedPage = nil
       isLoading = false
    }
}
        






    //        var request = URLRequest(url: url)
    //        request.setValue("Bearer \(Constants.AccessKey)", forHTTPHeaderField: "Authorization")
    //
    //        currentTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
    //            guard let self = self else { return }
    //
    //            defer { self.currentTask = nil }
    //
    //            if let error = error {
    //                print("ошибка загрузки \(error)")
    //                return
    //        }
    //            guard let data = data else {
    //                print( "Нет данных")
    //                return
    //            }
    //
    //            do {
    //                let photosResults = try JSONDecoder().decode([PhotoResult].self, from: data)
    //                let newPhotos = photosResults.map { self.convert(photoResult: $0)}
    //
