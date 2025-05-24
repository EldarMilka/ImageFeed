//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Эльдар on 20.05.2025.
//

import UIKit
@preconcurrency import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController{
    @IBOutlet weak var webView: WKWebView!

    @IBOutlet weak var progressView: UIProgressView!
    
    weak var delegate: WebViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        loadAuthView()
    }
        
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
        dismiss(animated: true, completion: nil)
    }
        private func loadAuthView() {
            guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
                print("1")
                return
            }
            
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: Constants.accessKey),
                URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "scope", value: Constants.accessScope)
            ]
            
            guard let url = urlComponents.url else {
                print("2")
                return
            }
            
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
