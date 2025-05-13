//
//  Untitled.swift
//  ImageFeed
//
//  Created by Эльдар on 04.05.2025.
//

import UIKit


final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var LikeButtom: UIButton!
}
