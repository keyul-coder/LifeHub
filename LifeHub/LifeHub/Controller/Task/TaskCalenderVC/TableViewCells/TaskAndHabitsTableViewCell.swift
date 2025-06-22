//
//  TaskTableViewCell.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-22.
//
import UIKit

/// TaskTableViewCell
class TaskAndHabitsTableViewCell: UITableViewCell {
    
    /// @IBOutlet(s)
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskSubLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskDayLabel: UILabel!
    
    /// Carried Varaible(s)
    weak var parentVC: ParentVC!
    var selectedDate: Date!
    var modelTask: ToDoTask! {
        didSet {
            self.taskLabel.text = modelTask.title
            let date: Date = modelTask.isRecurring ? modelTask.date : selectedDate
            self.taskDayLabel.text = date.getWeekDay()
            self.taskDateLabel.text = date.get(.day).formatted()
            self.taskSubLabel.text = date.get12HoursTimeFromat()
        }
    }
    var modelHabit: GoalItem! {
        didSet {
            self.taskLabel.text = modelHabit.title
            self.taskDayLabel.text = modelHabit.date.getWeekDay()
            self.taskDateLabel.text = modelHabit.date.get(.day).formatted()
            self.taskSubLabel.text = "\(modelHabit.date.get12HoursTimeFromat()) - \(modelHabit.category))"
        }
    }
}
