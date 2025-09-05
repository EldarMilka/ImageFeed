import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    //private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()

    override func viewDidLoad() {
            super.viewDidLoad()
            setupLogo()
        view.backgroundColor = .ypBlack
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            // СЦЕНАРИЙ 1: Токен уже есть, загружаем профиль
            fetchProfile(token: token)
        } else {
            // СЦЕНАРИЙ 2: Токена нет, показываем экран авторизации
            showAuthScreen()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success:
                switchToTabBarController()

            case .failure(let error):
                print("❌ Ошибка загрузки профиля: \(error.localizedDescription)")
                // TODO: Показать ошибку пользователю
                showAuthScreen()
            }
        }
    }

    private func showAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }

    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }

            switch result {
            case .success(let token):
                print("✅ Токен получен: \(token)")
                self.oauth2TokenStorage.token = token
                // ✅ ВАЖНОЕ ИСПРАВЛЕНИЕ: Убираем вызов fetchProfile отсюда!
                // Мы просто сохранили токен. Этого достаточно.
                // Выйдя из экрана авторизации, мы снова окажемся в SplashViewController,
                // который в viewDidAppear увидит токен и сам вызовет fetchProfile.

            case .failure(let error):
                print("❌ Ошибка при получении токена: \(error.localizedDescription)")
                // Показываем экран авторизации снова, чтобы пользователь попробовал еще раз
                self.showAuthScreen()
            }
        }
    }
}

extension SplashViewController {
    private func  setupLogo() {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
            
            if let logoImage = UIImage(named: "splash_screen_logo"){
                logoImageView.image = logoImage
            } else {
                logoImageView.image = UIImage(systemName: "photo")
                print("фото splash_screen_logo не найдено")
            }
                logoImageView.contentMode = .scaleAspectFit
                view.addSubview(logoImageView)
                
                NSLayoutConstraint.activate([
                    logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
                    logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)
                   ])
               }
            }
        
    
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        // Закрываем экран авторизации
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            // Запускаем процесс получения токена по коду
            self.fetchOAuthToken(code)
        }
    }
}


//extension SplashViewController {
////    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
////            guard
////                let navigationController = segue.destination as? UINavigationController,
////                let viewController = navigationController.viewControllers[0] as? AuthViewController
////            else {
////                fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")
////            }
////            viewController.delegate = self
////        } else {
////            super.prepare(for: segue, sender: sender)
////        }
////    }
//}
//
//final class SplashViewController: UIViewController {
//    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
//
//    private let oauth2Service = OAuth2Service.shared
//    private let oauth2TokenStorage = OAuth2TokenStorage()
//    private var isFetchingToken = false // защита от повторного входа (для себя запомнить)
//   
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        if oauth2TokenStorage.token != nil {
//            switchToTabBarController()
//        } else {
//            // Show Auth Screen
//            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setNeedsStatusBarAppearanceUpdate()
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
//
//    private func switchToTabBarController() {
//        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
//        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
//            .instantiateViewController(withIdentifier: "TabBarViewController")
//        window.rootViewController = tabBarController
//    }
//}
//
//extension SplashViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
//            viewController.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//}
//
//extension SplashViewController: AuthViewControllerDelegate {
//    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
//        dismiss(animated: true) { [weak self] in
//            guard let self = self else { return }
//            self.isFetchingToken = true              //  Блокируем  вход повторный
//            UIBlockingProgressHUD.show()
//            self.fetchOAuthToken(code)
//        }
//    }
//    
//    private func fetchOAuthToken(_ code: String) {
//        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isFetchingToken = false  // разрешаем повторный вход
//                switch result {
//                case .success(let token):
//                    ProgressHUD.dismiss()
//                    print("✅ Токен получен: \(token)")
//                    OAuth2TokenStorage().token = token
//                    self.switchToTabBarController()
//                case .failure(let error):
//                    ProgressHUD.showFailed("Ошибка: \(error.localizedDescription)")
//                    print("❌ Ошибка при получении токена: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
