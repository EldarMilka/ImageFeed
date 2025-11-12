//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//
@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    var updateProfileCalled = false
    var updateAvatarCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var showLogoutConfirmationCalled = false
    var switchToSplashScreenCalled = false
    
    var updatedName: String?
    var updatedLoginName: String?
    var updatedBio: String?
    var updatedAvatarURL: URL?
    
    func updateProfile(name: String, loginName: String, bio: String?) {
        updateProfileCalled = true
        updatedName = name
        updatedLoginName = loginName
        updatedBio = bio
    }
    
    func updateAvatar(imageURL: URL?) {
        updateAvatarCalled = true
        updatedAvatarURL = imageURL
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
    
    func switchToSplashScreen() {
        switchToSplashScreenCalled = true
    }
}
