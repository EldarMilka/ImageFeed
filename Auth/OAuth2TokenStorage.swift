//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 13.06.2025.
//

// OAuth2TokenStorage.swift

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "OAuthToken"

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
