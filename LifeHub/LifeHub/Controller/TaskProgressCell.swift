//
//  TaskProgressCell.swift
//  LifeHub
//
//  Created by Keyul patel on 2025-07-19.
//

import UIKit

class TaskProgressCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func configure(with tasks: [ToDoTask]) {
        let totalTasks = tasks.count
        let completedTasks = tasks.filter { $0.isCompleted }.count
        let pendingTasks = totalTasks - completedTasks
        
        titleLabel.text = "Task Progress"
        
        if totalTasks == 0 {
            descriptionLabel.text = "No tasks for today\nAdd some tasks to get started!"
        } else {
            let completionPercentage = totalTasks > 0 ? Int(Double(completedTasks) / Double(totalTasks) * 100) : 0
            descriptionLabel.text = "\(completedTasks) of \(totalTasks) tasks completed\n\(pendingTasks) pending • \(completionPercentage)% done"
        }
        
        iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        iconImageView.tintColor = completedTasks == totalTasks && totalTasks > 0 ? .systemGreen : .systemBlue
    }
}
