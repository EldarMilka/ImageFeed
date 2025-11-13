//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Эльдар on 28.04.2025.
//
import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    
    var presenter: ImagesListPresenterProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    
    // Для хранения градиентных вью
    private var gradientViews: [IndexPath: GradientAnimationView] = [:]
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
   
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🟢 ImagesListViewController: viewDidLoad")
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        print("🔗 ImagesListViewController: presenter = \(presenter != nil ? "установлен" : "НЕ установлен")")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllGradientAnimations()
    }
    
    // MARK: - ImagesListViewControllerProtocol
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        print("🟡 ImagesListViewController: updateTableViewAnimated - было: \(oldCount), стало: \(newCount)")
        
        guard newCount > oldCount else {
            print("🟡 ImagesListViewController: Просто перезагружаем таблицу")
            tableView.reloadData()
            return
        }
        
        print("🟡 ImagesListViewController: Анимированное обновление с \(oldCount) до \(newCount)")
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func initializeAfterPresenterSetup() {
        print("🚀 ImagesListViewController: initializeAfterPresenterSetup - презентер готов!")
        presenter?.viewDidLoad()
    }
    
    func showGradientForCell(at indexPath: IndexPath, in cell: ImagesListCell) {
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
    
    func hideGradientForCell(at indexPath: IndexPath) {
        if let gradientView = gradientViews[indexPath] {
            gradientView.stopAnimating()
            gradientView.removeFromSuperview()
            gradientViews.removeValue(forKey: indexPath)
        }
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = presenter?.photosCount ?? 0
        print("📊 UITableViewDataSource: numberOfRowsInSection = \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell,
              let photo = presenter?.photo(at: indexPath.row) else {
            print("❌ UITableViewDataSource: Не удалось создать ячейку для indexPath: \(indexPath)")
            return UITableViewCell()
        }
        
        print("📱 UITableViewDataSource: Настраиваем ячейку для indexPath: \(indexPath), photo: \(photo.id)")
        configCell(for: imageListCell, with: indexPath, photo: photo)
        return imageListCell
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath, photo: Photo) {
        // Показываем градиент
        showGradientForCell(at: indexPath, in: cell)
        
        cell.configure(with: photo)
        cell.delegate = self
        cell.cellImage.image = nil
        
        if let url = URL(string: photo.thumbImageURL) {
            print("🌐 Загружаем изображение для indexPath: \(indexPath), URL: \(photo.thumbImageURL)")
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
        } else {
            print("❌ Неверный URL для indexPath: \(indexPath)")
        }
        
        if let date = photo.createdAt {
            cell.DateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.DateLabel.text = ""
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = presenter?.photo(at: indexPath.row) else { return }
        
        let newLikeState = !photo.isLiked
        presenter?.changeLike(photoId: photo.id, isLike: newLikeState)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalCount = presenter?.photosCount ?? 0
        print("👀 UITableViewDelegate: willDisplay cell at \(indexPath), всего: \(totalCount)")
        
        if indexPath.row == totalCount - 1 {
            print("🔄 UITableViewDelegate: Достигнут конец, загружаем следующую страницу")
            presenter?.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        hideGradientForCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photo = presenter?.photo(at: indexPath.row)
            else { return }
            
            if let url = URL(string: photo.fullImageUrl) {
                viewController.fullImageUrl = url
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath.row),
              let presenter = presenter else { return 200 }
        
        let height = presenter.calculateCellHeight(for: photo, tableViewWidth: tableView.bounds.width)
        print("📏 UITableViewDelegate: heightForRowAt \(indexPath) = \(height)")
        return height
    }
}
