//
//   ProfileTests.swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled, "ViewController should call presenter's viewDidLoad")
        
    }
    
    func testPresenterCallsUpdateProfile() {
        // given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceSpy()
        
        // Создаем mock ProfileResult и Profile
        let mockProfileResult = ProfileResult(
            username: "testuser",
            firstName: "Test",
            lastName: "User",
            bio: "Test bio"
        )
        let mockProfile = Profile(from: mockProfileResult, nil)
        profileService.mockProfile = mockProfile
        
        let presenter = ProfilePresenter(profileService: profileService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.updateProfileDetails()
        
        // then
        XCTAssertTrue(viewController.updateProfileCalled, "Presenter should call view's updateProfile")
        XCTAssertEqual(viewController.updatedName, "Test User")
        XCTAssertEqual(viewController.updatedLoginName, "@testuser")
        XCTAssertEqual(viewController.updatedBio, "Test bio")
    }
    
    func testPresenterCallsLogoutConfirmation() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(viewController.showLogoutConfirmationCalled, "Presenter should call showLogoutConfirmation when logout tapped")
    }
    
    func testPresenterCallsUpdateAvatar() {
        // given
        let viewController = ProfileViewControllerSpy()
        let profileImageService = ProfileImageServiceSpy()
        profileImageService.mockAvatarURL = "https://example.com/avatar.jpg"
        
        let presenter = ProfilePresenter(profileImageService: profileImageService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.updateAvatar()
        
        // then
        XCTAssertTrue(viewController.updateAvatarCalled, "Presenter should call updateAvatar")
        XCTAssertEqual(viewController.updatedAvatarURL?.absoluteString, "https://example.com/avatar.jpg")
    }
}
