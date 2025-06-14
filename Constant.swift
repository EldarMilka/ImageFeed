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
}
