//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool)
    func photo(at index: Int) -> Photo?
    var photosCount: Int { get }
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat
}
