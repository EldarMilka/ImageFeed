//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 13.06.2025.
//

// OAuth2TokenStorage.swift

import Foundation
import SwiftKeychainWrapper


final class OAuth2TokenStorage {
    private let tokenKey = "OAuthToken"

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
                
                if !isSuccess {
                                    print("⚠️ Ошибка: не удалось сохранить токен в Keychain")
                                }
                            } else {
                                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
