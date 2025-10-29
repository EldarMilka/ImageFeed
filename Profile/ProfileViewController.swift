//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Эльдар on 05.05.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let profileService = ProfileService.shared
    private let processor = RoundCornerImageProcessor(cornerRadius: 35)
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var gradientLayers: [CAGradientLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showProfileSkeleton()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main)
        {[weak self] _ in guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
        
        view.backgroundColor = .ypBlack
        
        setupViews()
        setupConstraints()
        updateProfileDetails()
        loadAvatarImage()
        
        setupProfileNotifications()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        if profileService.profile != nil {
            hideProfileSkeleton()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    private func setupProfileNotifications() {
        NotificationCenter.default.addObserver(
            forName: ProfileService.didChangeNotification,
            object: nil,
            queue: .main)
        { [weak self] _ in
            self?.hideProfileSkeleton()
            self?.updateProfileDetails()
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showProfileSkeleton() {
        
        hideProfileSkeleton()
        
        
        addGradientSkeleton(to: avatarImageView, size: CGSize(width: 70, height: 70), cornerRadius: 35 )
        
        addGradientSkeleton(to: nameLabel, size: CGSize(width: 200, height: 24), cornerRadius: 8 )
        
        addGradientSkeleton(to: loginNameLabel, size: CGSize(width: 150, height: 18 ), cornerRadius: 6 )
        
        addGradientSkeleton(to: descriptionLabel, size: CGSize(width: 250, height: 36), cornerRadius: 6 )
        
        startGradientAnimation()
        
        nameLabel.text = ""
        loginNameLabel.text = ""
        descriptionLabel.text = ""
    }
    
    
    private func hideProfileSkeleton() {
        gradientLayers.forEach{
            gradient in
            gradient.removeAllAnimations()
            gradient.removeFromSuperlayer()
        }
        gradientLayers.removeAll()
        
        activityIndicator.stopAnimating()
    }
    
    
    
    private func addGradientSkeleton(to view: UIView, size: CGSize, cornerRadius: CGFloat){
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha:  1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        gradientLayers.append(gradient)
        view.layer.addSublayer(gradient)
    }
    
    private func startGradientAnimation() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        
        gradientLayers.forEach { gradient in
            gradient.add(animation, forKey: "skeletonAnimation")
        }
    }
    
    
    
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Выйти из аккаунта?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "ДА", style: .default) { [weak self] _ in
            ProfileLogoutService.shared.logout()
            self?.switchToSplashScreen()
        })
        
        alert.addAction(UIAlertAction(title: "НЕТ", style: .cancel))
        present(alert, animated: true)
    }
    
    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }
    
    private func updateAvatar() {
        guard
            let profileImageUrl = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageUrl)
        else { return }
        
        avatarImageView.kf.setImage(with: url)
    }
    
    private func setupViews() {
        [avatarImageView, nameLabel, loginNameLabel, logoutButton, descriptionLabel, activityIndicator].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadAvatarImage() {
        guard let profile = profileService.profile,
              let profileImage = profile.profileImage else {
            setPlaceholderImage()
            return
        }
        guard let url = URL(string: profileImage.large) else {
            setPlaceholderImage()
            return
        }
        
        avatarImageView.kf.indicatorType = .activity
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: createPlaceholderImage(),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.3))
            ]) { [weak self] result in
                switch result {
                case .success(let value):
                    print("✅ Аватар загружен успешно")
                    print("Изображение: \(value.image)")
                    print("Тип кэша: \(value.cacheType)")
                    print("Источник: \(value.source)")
                case .failure(let error):
                    print("❌ Ошибка загрузки: \(error)")
                    self?.setPlaceholderImage()
                }
            }
    }
    
    private func createPlaceholderImage() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .large)
        return UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(config)
    }
    
    private func setPlaceholderImage() {
        avatarImageView.image = createPlaceholderImage()
        avatarImageView.contentMode = .center
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            activityIndicator.startAnimating()
            return
        }
        
        activityIndicator.stopAnimating()
        
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "Нет описания"
        
        if let profileImage = profile.profileImage {
            print("\(profileImage)")
        }
    }
}
