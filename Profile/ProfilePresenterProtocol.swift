//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//

import Foundation

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func updateProfileDetails()
    func updateAvatar()
    func performLogout()
}
