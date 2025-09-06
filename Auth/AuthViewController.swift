//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Эльдар on 20.05.2025.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let showWebView = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            performSegue(withIdentifier: showWebView, sender: self)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebView" {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("Не удалось привести segue.destination к WebViewViewController")
                return
            }
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func showNetworkErrorAlert(message: String? = nil) {  // добавил алерт при ошибке
        let alert = UIAlertController(title: "что-то пошло не так",
                                      message: message ?? "Не удалось войти в систему",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        ProgressHUD.show("Loading…")
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        print("📥 Получен код авторизации: \(code)")
  
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}


