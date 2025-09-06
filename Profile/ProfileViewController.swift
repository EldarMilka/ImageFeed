//
//  Untitled.swift
//  ImageFeed
//
//  Created by Эльдар on 05.05.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "Photo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack

        setupViews()
        setupConstraints()
        updateProfileDetails()
        loadAvatarImage()
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

        // задачи по отображению картинки нет, поэтому просто отображаем
        if let profileImage = profile.profileImage {
            print("\(profileImage)")
        }
    }
}


