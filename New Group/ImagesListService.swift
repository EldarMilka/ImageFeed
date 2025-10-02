//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 06.09.2025.
//

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLike: Bool
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    
    func fetchPhotoNextPage() {
        
    }
}
