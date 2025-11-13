//
//  Constant.swift
//  ImageFeed
//
//  Created by Эльдар on 16.05.2025.
//
import Foundation

enum Constants {
    static let AccessKey = "75LLiJPX8NT0M2UlEQW2o3GZOaJqzcB25EY9qRcFdOc"
    static let SecretKey = "y-8fYsVhuKmXHts69MVSoBsiJ5iG84iPt4rT3rWDelo"
    static let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let AccessScope = "public+read_user+write_likes"
    static let DefaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("⚠️ Invalid DefaultBaseURL string")
        }
        return url
    }()
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.AccessKey,
                                 secretKey: Constants.SecretKey,
                                 redirectURI: Constants.RedirectURI,
                                 accessScope: Constants.AccessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.DefaultBaseURL)
    }
}
 

