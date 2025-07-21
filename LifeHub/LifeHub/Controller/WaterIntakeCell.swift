//
//  WaterIntakeCell.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-06-19.
//

import UIKit

class WaterIntakeCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func configure(with intake: Int, goal: Int = 2500) {
        titleLabel.text = "Water Intake"
        descriptionLabel.text = "You've consumed \(intake)ml today\n\(Int(Double(intake)/Double(goal)*100))% of your daily goal"
        iconImageView.image = UIImage(systemName: "drop.fill")
    }
}
