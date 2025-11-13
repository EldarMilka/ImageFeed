//
//  AuthHelperSpy.swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 06.11.2025.
//

import Foundation
@testable import ImageFeed

final class AuthHelperSpy: AuthHelperProtocol {
    var authRequestCalled = false
    func authRequest() -> URLRequest? {
        var authRequestCalled = true
        return URLRequest(url: URL(string: "https://test.com")!)
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    
}
