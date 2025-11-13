//
//  ProfileImageServiceSpy.swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.

@testable import ImageFeed
import Foundation

final class ProfileImageServiceSpy: ProfileImageServiceProtocol {
    var mockAvatarURL: String?
    
    var avatarURL: String? {
        return mockAvatarURL
    }
    
    func fetchProfileImageUrl(username: String, completion: @escaping (Result<String, Error>) -> Void) {  // ← УБРАЛ _
        // Для тестов не реализуем
    }
}
