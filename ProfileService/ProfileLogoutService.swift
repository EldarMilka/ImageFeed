//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 25.10.2025.
//

import Foundation

import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanProfileData()
        cleanCookies()
    }
    
    private func cleanProfileData() {
        // 1. Очищаем данные профиля
               ProfileService.shared.clean()
               
               // 2. Очищаем аватарку
               ProfileImageService.shared.clean()
               
               // 3. Очищаем список фотографий
               ImagesListService.shared.clean()
               
               // 4. Очищаем OAuth токен
               OAuth2TokenStorage.shared.clean()
               
               print("✅ Все данные пользователя очищены")
           }
    
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                
            }
        }
        print("✅ Куки и данные веб-хранилища очищены")
    }
}
