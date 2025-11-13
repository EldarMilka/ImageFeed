//
//  ProfileServiceProtocol.swift
//  ImageFeed
//

import Foundation

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

// Сделаем ProfileService совместимым с протоколом
extension ProfileService: ProfileServiceProtocol {}
