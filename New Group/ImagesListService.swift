//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 06.09.2025.
//
import Foundation

public final class ImagesListService {
   public  private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var perPage: Int = 10
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    public static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
   public  static let shared = ImagesListService(); private init(){}
    
    
   public  func fetchPhotosNextPage() {
       print("🟡 Начинаем загрузку страницы...")
        //если идет закачка то прерываем
        guard currentTask == nil else {print("🔴 Уже идет загрузка, прерываем")
         return }
        
        // Здесь получим страницу номер 1, если ещё не загружали ничего,
        // и следующую страницу (на единицу больше), если есть предыдущая загруженная страница
        let nextPage = (lastLoadedPage ?? 0) + 1
       print("🟡 Загружаем страницу: \(nextPage)")

      
       // guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else
      // guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos?_page=1&_limit=1") else
       guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else { print("🔴 Неверный URL")
            return }
       print("🟡 URL: \(url)")
       
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Constants.AccessKey)", forHTTPHeaderField: "Authorization")
        
        currentTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { self.currentTask = nil }
            
            if let error = error {
                print("ошибка загрузки \(error)")
                return
        }
            guard let data = data else {
                print( "Нет данных")
                return
            }
            
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
        }
        currentTask?.resume()
    }
    private func convert(photoResult: PhotoResult) -> Photo {
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = photoResult.createdAt.flatMap { dateFormatter.date(from: $0) }
        
        return Photo(
            id: photoResult.id ?? "",
            size: CGSize(width: photoResult.width ?? 0, height: photoResult.height ?? 0),
            createdAt: createdAt,
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb ?? "",
            largeImageURL: photoResult.urls.regular ?? "",
            isLiked: photoResult.likedByUser ?? false
        )
    }
    
    // Дополнительные методы для очистки (опционально)
   public func clean() {
        photos = []
        lastLoadedPage = nil
        currentTask?.cancel()
        currentTask = nil
    }
}
