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
    
    func configure(with intake: Int, goal: Int = WaterIntakeConstants.defaultDailyGoal) {
        titleLabel.text = "Water Intake"
        let calculatedPercentage = Int(Double(intake) / Double(goal) * 100)
        let percentage = Swift.min(calculatedPercentage, 100)
        descriptionLabel.text = "You've consumed \(intake)ml today\n\(percentage)% of your daily goal"
        iconImageView.image = UIImage(systemName: "drop.fill")
        iconImageView.tintColor = percentage >= 100 ? .systemGreen : .systemBlue
    }
    
    func configure(with records: [WaterIntake]) {
        let totalIntake = records.totalIntake
        let percentage = records.intakePercentage()
        
        titleLabel.text = "Water Intake"
        descriptionLabel.text = "You've consumed \(totalIntake)ml today\n\(percentage)% of your daily goal"
        iconImageView.image = UIImage(systemName: "drop.fill")
        iconImageView.tintColor = percentage >= 100 ? .systemGreen : .systemBlue
    }
}
