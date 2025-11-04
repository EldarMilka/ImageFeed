// GradientAnimationView.swift
import UIKit

final class GradientAnimationView: UIView {
    
    // MARK: - Public Properties
    var gradientColors: [UIColor] = [
        UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1),
        UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1),
        UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1)
    ] {
        didSet {
            updateGradientColors()
        }
    }
    
    var animationDuration: TimeInterval = 1.0
    var cornerRadius: CGFloat = 0 {
        didSet {
            gradientLayer.cornerRadius = cornerRadius
        }
    }
    
    // MARK: - Private Properties
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 0.1, 0.3]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.masksToBounds = true
        return layer
    }()
    
    private var isAnimating = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        // Гарантируем остановку анимации при деините
        stopAnimating()
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Public Methods
    func startAnimating() {
        guard !isAnimating else { return }
        
        isAnimating = true
        isHidden = false
        layer.addSublayer(gradientLayer)
        addAnimation()
    }
    
    func stopAnimating() {
        guard isAnimating else { return }
        
        isAnimating = false
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
    }
    
    func isAnimationRunning() -> Bool {
        return isAnimating
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundColor = .clear
        updateGradientColors()
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = gradientColors.map { $0.cgColor }
    }
    
    private func addAnimation() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = animationDuration
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: "locationsChange")
    }
}
