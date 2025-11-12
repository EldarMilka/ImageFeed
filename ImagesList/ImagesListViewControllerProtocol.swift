//
//  ImagesListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showGradientForCell(at indexPath: IndexPath, in cell: ImagesListCell)
    func hideGradientForCell(at indexPath: IndexPath)
    func reloadRows(at indexPaths: [IndexPath])
    func showErrorAlert(title: String, message: String)
    func initializeAfterPresenterSetup()
}
