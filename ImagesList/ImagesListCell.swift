//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Эльдар on 04.05.2025.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var LikeButtom: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    var photoId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        LikeButtom.accessibilityIdentifier = "likeButton"
    }
    
    func configure(with photo: Photo) {
        self.photoId = photo.id
        let likeButtonIdentifier = photo.isLiked ? "like button on" : "like button off"
        LikeButtom.accessibilityIdentifier = likeButtonIdentifier
        setIsLiked(photo.isLiked)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        LikeButtom.setImage(likeImage, for: .normal)
        
        let likeButtonIdentifier = isLiked ? "like button on" : "like button off"
                LikeButtom.accessibilityIdentifier = likeButtonIdentifier
    }
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        guard let photoId else {
            print("❌ ImagesListCell: photoId не найден")
            return
        }
        
        print("🟡 ImagesListCell: Нажата кнопка лайка для photoId: \(photoId)")
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoId = nil
        delegate = nil
        cellImage.kf.cancelDownloadTask()
        cellImage.image = UIImage(named: "load")
        
        LikeButtom.accessibilityIdentifier = "likeButton"
    }
}
