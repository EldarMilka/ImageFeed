import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    //private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
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
            
            print("🔍 SplashViewController: Начинаем поиск контроллеров...")
            
            // НАСТРАИВАЕМ ПРЕЗЕНТЕР ДЛЯ ВСЕХ КОНТРОЛЛЕРОВ
            if let tabBar = tabBarController as? UITabBarController,
               let viewControllers = tabBar.viewControllers {
                
                print("🔍 SplashViewController: Найдено контроллеров в TabBar: \(viewControllers.count)")
                
                for (index, controller) in viewControllers.enumerated() {
                    print("🔍 SplashViewController: Контроллер \(index): \(type(of: controller))")
                    
                    // НАСТРОЙКА IMAGESLISTVIEWCONTROLLER
                    if let imagesListVC = controller as? ImagesListViewController {
                        print("✅ SplashViewController: НАЙДЕН ImagesListViewController! Настраиваем презентер...")
                        let imagesListPresenter = ImagesListPresenter()
                        imagesListVC.presenter = imagesListPresenter
                        imagesListPresenter.view = imagesListVC
                        print("🔗 SplashViewController: Презентер установлен: \(imagesListVC.presenter != nil)")
                        print("🔗 SplashViewController: View установлен: \(imagesListPresenter.view != nil)")
                        
                        // ВЫЗЫВАЕМ ИНИЦИАЛИЗАЦИЮ ПОСЛЕ НАСТРОЙКИ ПРЕЗЕНТЕРА
                            imagesListVC.initializeAfterPresenterSetup()
                    }
                    
                    // НАСТРОЙКА PROFILEVIEWCONTROLLER
                    if let profileVC = controller as? ProfileViewController {
                        print("✅ SplashViewController: НАЙДЕН ProfileViewController! Настраиваем презентер...")
                        let profilePresenter = ProfilePresenter()
                        profileVC.presenter = profilePresenter
                        profilePresenter.view = profileVC
                    }
                }
            }
            
            print("🚀 SplashViewController: Переключаем rootViewController на TabBarController")
            window.rootViewController = tabBarController
        }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(_):
                if let username = self.profileService.profile?.username {
                    ProfileImageService.shared.fetchProfileImageUrl(username: username) {result in
                    }
                    switch result {
                    case .success:
                        print("✅ Аватар успешно загружен")
                    case .failure(let error) :
                        print("❌ Ошибка загрузки аватара: \(error.localizedDescription)")
                    }
                    self.switchToTabBarController()
                }
                else {
                    self.switchToTabBarController()
                }
            case .failure(let error):
                print("❌ Ошибка загрузки профиля: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Создаем новый экземпляр AuthViewController для показа алерта
                    self.showNetworkErrorAlert(message: "Не удалось войти в систему")                   //showAuthScreen()
                }
            }
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
                fetchProfile(token: token)
            case .failure(let error):
                print("❌ Ошибка при получении токена: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Создаем новый экземпляр AuthViewController для показа алерта
                    self.showNetworkErrorAlert(message: "Не удалось войти в систему")                   //showAuthScreen()
                }
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
        
        let logoWidth: CGFloat = 75
        let logoHeight: CGFloat = 77.68
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 368),
            logoImageView.widthAnchor.constraint(equalToConstant: logoWidth),
            logoImageView.heightAnchor.constraint(equalToConstant: logoHeight)
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
