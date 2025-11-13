//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 06.11.2025.
//

import Foundation
@testable import ImageFeed

class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false
    var loadRequestURL: URLRequest?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
        loadRequestURL = request
    }
    
    func setProgressValue(_ newValue: Float) {
                
    }
    
    func setProgressHidden(_ isHidden: Bool) {
            
    }
    
    
    
}
