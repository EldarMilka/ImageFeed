//
//  ProfilePresenterSpy..swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//
@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var performLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
    
    func updateProfileDetails() {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func performLogout() {
        performLogoutCalled = true
    }
}
