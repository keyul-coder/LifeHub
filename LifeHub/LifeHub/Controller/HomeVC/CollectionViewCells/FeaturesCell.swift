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
            self.featureSubtitleLabel.text = type.subTitle
        }
    }
}
