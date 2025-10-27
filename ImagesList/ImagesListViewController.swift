//
//  ViewController.swift
//  ImageFeed
//
//  Created by Эльдар on 28.04.2025.
//

import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
   
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        print("🟡 ImagesListViewController: Запускаем загрузку фото")
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func updateTableViewAnimated() {
        print("🟡 Получена нотификация об изменении фото")
        
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        print("🟡 Старое количество: \(oldCount), Новое количество: \(newCount)")
        photos = imagesListService.photos
        
        tableView.performBatchUpdates{
            let indexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🟡 Количество фото для таблицы: \(photos.count)")
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🟡 Создаем ячейку для indexPath: \(indexPath)")
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            print("❌ Не удалось привести к ImagesListCell")
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.configure(with: photo)
        cell.delegate = self
        
        cell.cellImage.image = UIImage(named: "load")
        cell.cellImage.kf.indicatorType = .activity
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "load"),
                options: [.transition(.fade(0.3))])
        }
        
        if let date = photo.createdAt {
            cell.DateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.DateLabel.text = ""
        }
    }
    
    private func setLike(photoId: String, isLike: Bool, cell: ImagesListCell, indexPath: IndexPath) {
        print("🟡 ImagesListViewController: Устанавливаем лайк \(isLike) для \(photoId)")
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                print("✅ ImagesListViewController: Лайк успешно \(isLike ? "поставлен" : "удален")")
                
                DispatchQueue.main.async {
                    if let updatedPhoto = self?.imagesListService.photos.first(where: { $0.id == photoId }) {
                        cell.setIsLiked(updatedPhoto.isLiked)
                    }
                }
                
            case .failure(let error):
                print("❌ ImagesListViewController: Ошибка лайка - \(error)")
                
                DispatchQueue.main.async {
                    if let updatedPhoto = self?.imagesListService.photos.first(where: { $0.id == photoId }) {
                        cell.setIsLiked(updatedPhoto.isLiked)
                    }
                    
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось \(isLike ? "поставить" : "убрать") лайк",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        print("🟡 ImagesListCellDelegate: получено нажатие лайка")
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("❌ Не удалось найти indexPath для ячейки")
            return
        }
        
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        print("🟡 Меняем лайк для photoId: \(photo.id), новое состояние: \(newLikeState)")
        setLike(photoId: photo.id, isLike: newLikeState, cell: cell, indexPath: indexPath)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("🟡 Будет отображена ячейка: \(indexPath.row)")
        if indexPath.row == photos.count - 1 {
            print("🟡 Достигли конца - загружаем следующую страницу")
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            if let url = URL(string: photo.fullImageUrl) {
                viewController.fullImageUrl = url
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func updateCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}
