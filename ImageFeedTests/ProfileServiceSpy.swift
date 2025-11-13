//
//  ProfileServiceSpy.swift
//  ImageFeedTests
//

@testable import ImageFeed
import Foundation

final class ProfileServiceSpy: ProfileServiceProtocol {
    var mockProfile: Profile?
    
    var profile: Profile? {
        return mockProfile
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        // Для тестов не реализуем
    }
}
