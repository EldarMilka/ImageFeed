//
//  ImagesListViewController.swift
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
    
    // Для хранения градиентных вью
    private var gradientViews: [IndexPath: GradientAnimationView] = [:]
   
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllGradientAnimations()
    }
    
    @objc private func updateTableViewAnimated() {
        print("🟡 Получена нотификация об изменении фото")
        
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        guard newCount > oldCount else {
            photos = imagesListService.photos
            tableView.reloadData()
            return
        }
        
        let newPhotos = Array(imagesListService.photos[oldCount..<newCount])
        photos.append(contentsOf: newPhotos)
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    private func stopAllGradientAnimations() {
        gradientViews.values.forEach { $0.stopAnimating() }
        gradientViews.removeAll()
    }
    
    deinit {
        stopAllGradientAnimations()
        NotificationCenter.default.removeObserver(self)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        // Сначала показываем градиент
        showGradientForCell(cell, at: indexPath)
        
        cell.configure(with: photo)
        cell.delegate = self
        cell.cellImage.image = nil
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "load"),
                options: [.transition(.fade(0.3))]) { [weak self] result in
                    self?.hideGradientForCell(at: indexPath)
                    switch result {
                    case .success:
                        print("✅ Изображение загружено для indexPath: \(indexPath)")
                    case .failure(let error):
                        print("❌ Ошибка загрузки изображения: \(error)")
                    }
                }
        }
        
        if let date = photo.createdAt {
            cell.DateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.DateLabel.text = ""
        }
    }
    
    private func showGradientForCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        hideGradientForCell(at: indexPath)
        
        let gradientView = GradientAnimationView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.cornerRadius = 16
        gradientView.isHidden = false
        
        cell.contentView.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: cell.cellImage.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cell.cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cell.cellImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cell.cellImage.bottomAnchor)
        ])
        
        gradientViews[indexPath] = gradientView
        gradientView.startAnimating()
    }
    
    private func hideGradientForCell(at indexPath: IndexPath) {
        if let gradientView = gradientViews[indexPath] {
            gradientView.stopAnimating()
            gradientView.removeFromSuperview()
            gradientViews.removeValue(forKey: indexPath)
        }
    }
    
    private func setLike(photoId: String, isLike: Bool, cell: ImagesListCell, indexPath: IndexPath) {
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let updatedPhoto = self?.imagesListService.photos.first(where: { $0.id == photoId }) {
                        cell.setIsLiked(updatedPhoto.isLiked)
                    }
                }
                
            case .failure:
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
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        setLike(photoId: photo.id, isLike: newLikeState, cell: cell, indexPath: indexPath)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        hideGradientForCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            
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
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func updateCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}
