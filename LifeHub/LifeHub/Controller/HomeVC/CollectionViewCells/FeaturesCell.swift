//
//  FeaturesCell.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

import UIKit

/// FeaturesCell
class FeaturesCell: UICollectionViewCell {
    
    @IBOutlet weak var featureImageView: UIImageView!
    @IBOutlet weak var featureTitleLabel: UILabel!
    @IBOutlet weak var featureSubtitleLabel: UILabel!
    
    weak var parentVC: HomeVC!
    var type: Features! {
        didSet {
            self.featureImageView.image = UIImage(systemName: type.systemImageName)
            self.featureTitleLabel.text = type.title
            switch self.type {
            case .finances:
                self.featureSubtitleLabel.text = "Manage your finances here"
            case .habits:
                self.featureSubtitleLabel.text = "Track your daily habits"
            case .wellness:
                self.featureSubtitleLabel.text = "Prioritize your wellness"
            case .tasks:
                self.featureSubtitleLabel.text = "Organize your tasks"
            case .none:
                return
            }
        }
    }
}
