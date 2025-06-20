//
//  DietPlanTableViewCell.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-06-19.
//

import UIKit

class DietPlanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dietNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        // Add some styling to the cell
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 4
        
        selectionStyle = .none
    }
    
    func configure(with dietPlan: DietPlan) {
        dietNameLabel.text = dietPlan.name
    }
}
