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
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.backgroundColor = .ypBlack
        return imageView
    }()
    
    private let avatarGradientView: GradientAnimationView = {
        let view = GradientAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 35
        view.isHidden = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let nameGradientView: GradientAnimationView = {
        let view = GradientAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginGradientView: GradientAnimationView = {
        let view = GradientAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 6
        view.isHidden = true
        return view
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
    
    private let descriptionGradientView: GradientAnimationView = {
        let view = GradientAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 6
        view.isHidden = true
        return view
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
        
        showGradientSkeleton()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main)
        {[weak self] _ in guard let self = self else { return }
            self.updateAvatar()
        }
        
        setupProfileNotifications()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        loadProfileData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllSkeletonAnimations()
    }
    
    private func showGradientSkeleton() {
        nameLabel.text = ""
        loginNameLabel.text = ""
        descriptionLabel.text = ""
        avatarImageView.image = nil
        activityIndicator.startAnimating()
        
        startAllSkeletonAnimations()
    }
    
    private func startAllSkeletonAnimations() {
        avatarGradientView.startAnimating()
        nameGradientView.startAnimating()
        loginGradientView.startAnimating()
        descriptionGradientView.startAnimating()
    }
    
    private func stopAllSkeletonAnimations() {
        avatarGradientView.stopAnimating()
        nameGradientView.stopAnimating()
        loginGradientView.stopAnimating()
        descriptionGradientView.stopAnimating()
    }
    
    private func loadProfileData() {
        updateProfileDetails()
        loadAvatarImage()
        updateAvatar()
        
        hideGradientSkeleton()
    }
    
    private func hideGradientSkeleton() {
        stopAllSkeletonAnimations()
        activityIndicator.stopAnimating()
    }
    
    private func setupProfileNotifications() {
        NotificationCenter.default.addObserver(
            forName: ProfileService.didChangeNotification,
            object: nil,
            queue: .main)
        { [weak self] _ in
            self?.updateProfileDetails()
        }
    }

    deinit {
        stopAllSkeletonAnimations()
        NotificationCenter.default.removeObserver(self)
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
        [avatarImageView, avatarGradientView,
         nameLabel, nameGradientView,
         loginNameLabel, loginGradientView,
         descriptionLabel, descriptionGradientView,
         logoutButton, activityIndicator].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            avatarGradientView.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            avatarGradientView.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            avatarGradientView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            avatarGradientView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.heightAnchor.constraint(equalToConstant: 28),
            
            nameGradientView.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            nameGradientView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameGradientView.widthAnchor.constraint(equalToConstant: 200),
            nameGradientView.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginNameLabel.heightAnchor.constraint(equalToConstant: 18),
            
            loginGradientView.topAnchor.constraint(equalTo: loginNameLabel.topAnchor),
            loginGradientView.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            loginGradientView.widthAnchor.constraint(equalToConstant: 150),
            loginGradientView.heightAnchor.constraint(equalTo: loginNameLabel.heightAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            
            descriptionGradientView.topAnchor.constraint(equalTo: descriptionLabel.topAnchor),
            descriptionGradientView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            descriptionGradientView.widthAnchor.constraint(equalToConstant: 250),
            descriptionGradientView.heightAnchor.constraint(equalToConstant: 36),
            
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
        
        let avatarUrlString = profileImage.large
        guard let url = URL(string: avatarUrlString) else {
            setPlaceholderImage()
            return
        }
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: createPlaceholderImage(),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5))
            ]) { [weak self] result in
                switch result {
                case .success(let value):
                    print("✅ Аватар загружен успешно. Размер: \(value.image.size)")
                case .failure(let error):
                    print("❌ Ошибка загрузки: \(error)")
                    self?.setPlaceholderImage()
                }
            }
    }
    
    private func createPlaceholderImage() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .large)
        return UIImage(systemName: "person.circle.fill")?
            .withTintColor(.ypGray, renderingMode: .alwaysOriginal)
            .withConfiguration(config)
    }
    
    private func setPlaceholderImage() {
        avatarImageView.image = createPlaceholderImage()
        avatarImageView.contentMode = .center
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
        
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "Нет описания"
    }
}
