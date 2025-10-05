//
//  ImagesListModels.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 06.09.2025.
//

import Foundation

struct PhotoResult: Codable {
    let id: String?
    let createdAt: String?
    let updatedAt: String?
    let width: Int?
    let height: Int?
    let color: String?
    let blurHash: String?
    let likes: Int?
    let likedByUser: Bool?
    let description: String?
    let urls: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}


struct UrlsResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small : String?
    let thumb: String?
    
    private enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb
    }
}

public struct Photo {
    public let id: String
    public let size: CGSize
    public let createdAt: Date?
    public let welcomeDescription: String?
    public let thumbImageURL: String
    public let largeImageURL: String
    public let isLiked: Bool
    
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case createdAt = "created_at"
//        case welcomeDescription = "description"
//        case thumbImageURL = "urls.thumb"
//        case largeImageURL = "urls.regular"
//        case isLiked = "likes"
//    }
}
