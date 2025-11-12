//
//  ProfilePresenter.swift
//  ImageFeed
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutService
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared,
         profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
         logoutService: ProfileLogoutService = .shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        view?.showLoading()
        setupNotifications()
        updateProfileDetails()
        updateAvatar()
        view?.hideLoading()
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        view?.updateProfile(
            name: profile.name.isEmpty ? "Имя не указано" : profile.name,
            loginName: profile.loginName,
            bio: profile.bio ?? "Нет описания"
        )
    }
    
    func updateAvatar() {
        guard let avatarURLString = profileImageService.avatarURL,
              let url = URL(string: avatarURLString) else { return }
        view?.updateAvatar(imageURL: url)
    }
    
    func performLogout() {
        logoutService.logout()
        view?.switchToSplashScreen()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: ProfileService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProfileDetails()
        }
        
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
}
