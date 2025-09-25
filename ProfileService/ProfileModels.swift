//
//  ProfileModels.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 25.08.2025.
//

import Foundation

// Для GET /me
struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

// Для GET /users/:username
struct ProfileImageResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

// Чистая модель для UI слоя
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    let profileImage: ProfileImage?
    
    init(from result: ProfileResult, _ imageResult: ProfileImageResult?) {
        self.username = result.username
        self.name = "\(result.firstName ?? "") \(result.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(result.username)"
        self.bio = result.bio
        self.profileImage = imageResult?.profileImage
    }
}
