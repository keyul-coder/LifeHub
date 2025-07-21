//
//  BadgeCollectionViewCell.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-06-19.
//

import UIKit

class BadgeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeIconImageView: UIImageView!
    @IBOutlet weak var badgeNameLabel: UILabel!
    @IBOutlet weak var badgeRequirementLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    // MARK: - Setup Methods
    private func setupCell() {
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        // Setup shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        
        // Setup icon image view
        badgeIconImageView.contentMode = .scaleAspectFit
        badgeIconImageView.tintColor = .systemGray3
    }
    
    private func resetCell() {
        containerView.layer.borderWidth = 0
        containerView.layer.borderColor = UIColor.clear.cgColor
        badgeIconImageView.image = nil
        badgeNameLabel.text = nil
        badgeRequirementLabel.text = nil
    }
    
    // MARK: - Configuration
    func configure(with badge: Badge) {
        badgeNameLabel.text = badge.name
        badgeRequirementLabel.text = badge.requirement
        
        // Set icon
        badgeIconImageView.image = UIImage(systemName: badge.iconName)
        
        // Update appearance based on earned status
        updateAppearance(isEarned: badge.isEarned)
    }
    
    private func updateAppearance(isEarned: Bool) {
        if isEarned {
            // Earned badge appearance
            containerView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
            badgeIconImageView.tintColor = .systemYellow
            badgeNameLabel.textColor = .label
            badgeRequirementLabel.textColor = .secondaryLabel
            
            // Add golden border
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor.systemYellow.cgColor
            
            // Enhance shadow for earned badges
            layer.shadowOpacity = 0.2
            layer.shadowRadius = 6
        } else {
            // Unearned badge appearance
            containerView.backgroundColor = UIColor.systemGray6
            badgeIconImageView.tintColor = .systemGray3
            badgeNameLabel.textColor = .tertiaryLabel
            badgeRequirementLabel.textColor = .quaternaryLabel
            
            // Remove border
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
            
            // Subtle shadow for unearned badges
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 4
        }
    }
    
    // MARK: - Animation Methods
    func animateEarned() {
        // Scale animation when badge is earned
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity
            }
        }
        
        // Add sparkle effect
        addSparkleEffect()
    }
    
    private func addSparkleEffect() {
        let sparkleLayer = CAEmitterLayer()
        sparkleLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        sparkleLayer.emitterSize = bounds.size
        sparkleLayer.emitterShape = .circle
        sparkleLayer.lifetime = 1.0
        
        let sparkleCell = CAEmitterCell()
        sparkleCell.birthRate = 50
        sparkleCell.lifetime = 0.5
        sparkleCell.velocity = 50
        sparkleCell.velocityRange = 20
        sparkleCell.emissionRange = .pi * 2
        sparkleCell.scale = 0.1
        sparkleCell.scaleRange = 0.05
        sparkleCell.contents = UIImage(systemName: "sparkle")?.cgImage
        sparkleCell.color = UIColor.systemYellow.cgColor
        
        sparkleLayer.emitterCells = [sparkleCell]
        layer.addSublayer(sparkleLayer)
        
        // Remove sparkle effect after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sparkleLayer.removeFromSuperlayer()
        }
    }
}
