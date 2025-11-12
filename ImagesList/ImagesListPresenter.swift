//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListServiceProtocol // Используем протокол
    private var photos: [Photo] = []
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) { // Используем протокол
        self.imagesListService = imagesListService
    }
    
    var photosCount: Int {
        return photos.count
    }
    
    func viewDidLoad() {
        print("🟢 ImagesListPresenter: viewDidLoad вызван")
        setupNotifications()
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        print("🟢 ImagesListPresenter: fetchPhotosNextPage вызван")
        imagesListService.fetchPhotosNextPage()
    }
    
    func photo(at index: Int) -> Photo? {
        guard index >= 0 && index < photos.count else { return nil }
        return photos[index]
    }
    
    func changeLike(photoId: String, isLike: Bool) {
        print("🟡 ImagesListPresenter: changeLike - photoId: \(photoId), isLike: \(isLike)")
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    print("✅ ImagesListPresenter: Лайк успешно изменен")
                    
                    // КРИТИЧЕСКИ ВАЖНО: Обновляем photos из сервиса
                    self?.photos = self?.imagesListService.photos ?? []
                    
                    // Находим индекс обновленного фото и обновляем ячейку
                    if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                        let indexPath = IndexPath(row: index, section: 0)
                        print("🔄 ImagesListPresenter: Обновляем ячейку с индексом \(index)")
                        self?.view?.reloadRows(at: [indexPath])
                    } else {
                        print("❌ ImagesListPresenter: Не найден photoId \(photoId) в массиве photos")
                    }
                    
                case .failure(let error):
                    print("❌ ImagesListPresenter: Ошибка изменения лайка: \(error.localizedDescription)")
                    self?.view?.showErrorAlert(title: "Ошибка", message: "Не удалось изменить лайк: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handlePhotosUpdate()
        }
    }
    
     func handlePhotosUpdate() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        print("🟢 ImagesListPresenter: Обновление фото - было: \(oldCount), стало: \(newCount)")
        
        if newCount > 0 {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        } else {
            print("⚠️ ImagesListPresenter: Фото не загрузились")
        }
    }
}
