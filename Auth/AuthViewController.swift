//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Эльдар on 20.05.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let showWebView = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebView {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("Не удалось привести segue.destination к WebViewViewController")
                return
            }
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        print("📥 Получен код авторизации: \(code)")
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token):
                print("✅ Авторизация успешна! Access token: \(token)")

                OAuth2TokenStorage().token = token

              
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                }
                
                DispatchQueue.main.async {
                    self?.dismiss(animated: true) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let imagesListVC = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController {
                            imagesListVC.modalPresentationStyle = .fullScreen
                            self?.present(imagesListVC, animated: true)
                        } else {
                            print("❌ Не удалось найти ImagesListViewController по ID")
                        }
                    }
                }

            
            case .failure(let error):
                print("❌ Ошибка при получении токена: \(error.localizedDescription)")
                
                // Можно показать UIAlert:
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Не удалось получить токен. Попробуйте ещё раз.\n\(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
