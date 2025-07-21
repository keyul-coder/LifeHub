//
//  BudgetTableViewCell.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-07-05.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountPeriodLabel: UILabel!
    @IBOutlet weak var spentRemainingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var percentageLabel: UILabel!


        
    override func awakeFromNib() {
           super.awakeFromNib()

           // Round progress bar
           progressView.layer.cornerRadius = 4
           progressView.clipsToBounds = true
           progressView.trackTintColor = UIColor.systemGray5
           progressView.progressTintColor = UIColor.systemGreen

           // Text styles
           categoryLabel.font = UIFont.boldSystemFont(ofSize: 18)
           amountPeriodLabel.font = UIFont.systemFont(ofSize: 14)
           spentRemainingLabel.font = UIFont.systemFont(ofSize: 14)
           percentageLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

           // Text color
           amountPeriodLabel.textColor = .darkGray
           spentRemainingLabel.textColor = .darkGray
           percentageLabel.textColor = .systemGreen

           // Cell background and padding
           contentView.backgroundColor = .secondarySystemGroupedBackground
           contentView.layer.cornerRadius = 12
           contentView.layer.masksToBounds = true
           contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
       }

       func configure(with budget: Budget) {
           categoryLabel.text = budget.category

           let formatter = NumberFormatter()
           formatter.numberStyle = .currency
           let amountText = formatter.string(from: NSNumber(value: budget.amount)) ?? "$0"
           let spentText = formatter.string(from: NSNumber(value: budget.spentAmount)) ?? "$0"
           let remaining = budget.amount - budget.spentAmount
           let remainingText = formatter.string(from: NSNumber(value: remaining)) ?? "$0"

           amountPeriodLabel.text = "\(amountText) • \(budget.timePeriod)"
           spentRemainingLabel.text = "Spent: \(spentText) | Left: \(remainingText)"

           let progress = budget.amount > 0 ? Float(budget.spentAmount / budget.amount) : 0
           progressView.progress = progress
           progressView.tintColor = progress >= Float(budget.alertThreshold) ? .systemRed : .systemGreen

           let percentage = Int(progress * 100)
           percentageLabel.text = "\(percentage)%"
       }

    }

