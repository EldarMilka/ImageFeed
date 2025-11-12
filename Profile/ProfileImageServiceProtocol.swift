//
//  ProfileImageServiceProtocol.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//
import Foundation

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageUrl(username: String, completion: @escaping (Result<String, Error>) -> Void)  // ← УБРАЛ _
}

extension ProfileImageService: ProfileImageServiceProtocol {}
