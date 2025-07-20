//
//  MainHeaderCollectionViewCell.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

import UIKit

class MainHeaderCollectionViewCell: UICollectionViewCell {
    
    /// @IBOutlet(s)
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lblUSerName: UILabel!
    @IBOutlet weak var lblTaksDoneValue: UILabel!
    @IBOutlet weak var lblDaysStreakValue: UILabel!
    @IBOutlet weak var lblWaterIntakePercentageValue: UILabel!
    
    /// Carried Varaiable(s)
    weak var parentVC: HomeVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Setup styling for the main header card
        self.layer.cornerRadius = 16
        self.layer.shadowColor = UIColor.label.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
        self.backgroundColor = .systemBackground
    }
    
    func updateWaterIntakePercentage(currentIntake: Int, dailyGoal: Int = WaterIntakeConstants.defaultDailyGoal) {
        let calculatedPercentage = Int(Double(currentIntake) / Double(dailyGoal) * 100)
        let percentage = Swift.min(calculatedPercentage, 100)
        self.lblWaterIntakePercentageValue.text = "\(percentage)%"
    }
    
    func updateWaterIntakeWithRecords(_ records: [WaterIntake]) {
        let percentage = records.intakePercentage()
        self.lblWaterIntakePercentageValue.text = "\(percentage)%"
    }
    
    func updateDayStreak() {
        // Get current streak from badge system
        let currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        self.lblDaysStreakValue.text = "\(currentStreak)"
    }
    
    func updateTasksDone() {
        // Get today's completed tasks count
        let completedCount = TaskManager.shared.getTodaysCompletedTasksCount()
        self.lblTaksDoneValue.text = "\(completedCount)"
    }
    
    
}
