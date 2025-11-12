//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//

import UIKit

public protocol ProfileViewControllerProtocol: AnyObject{
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfile(name: String, loginName: String, bio: String?)
        func updateAvatar(imageURL: URL?)
        func showLoading()
        func hideLoading()
        func showLogoutConfirmation()
        func switchToSplashScreen()
}
