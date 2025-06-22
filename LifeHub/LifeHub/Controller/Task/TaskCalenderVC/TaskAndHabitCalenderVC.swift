//
//  TaskAndHabitCalenderVC.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-22.
//

import FSCalendar
import UIKit

/// TaskCalenderVC
class TaskAndHabitCalenderVC: ParentVC {
    
    /// @IBOutlet(s)
    @IBOutlet weak var calendarView: FSCalendar!
    
    /// Carried Varaiable(s)
    var arrTasks: [ToDoTask] = []
    var arrGoals: [GoalItem] = []
    var isFromHabits: Bool = false
    
    /// Varaiable Declaration
    var fillterdTask: [ToDoTask] = []
    var arrFilterdHabits: [GoalItem] = []
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
    }
}

// MARK: - UI Related Method(s)
extension TaskAndHabitCalenderVC {
    
    private func prepareUI() {
        self.setupCalendar()
        self.handleDataPopulation()
    }
    
    private func setupCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.scope = .month
        calendarView.setCurrentPage(Date(), animated: false)
        calendarView.select(Date())
    }
    
    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func filterTaskByDate() {
        self.fillterdTask.removeAll()
        let selectedDate = self.calendarView.selectedDate ?? Date()
        self.fillterdTask = self.arrTasks.filter { (task) -> Bool in
            return Calendar.current.isDate(task.date, inSameDayAs: selectedDate) || task.isRecurring
        }
        self.reloadData()
    }
    
    private func filterHabbits() {
        self.arrFilterdHabits.removeAll()
        let selectedDate = self.calendarView.selectedDate ?? Date()
        self.arrFilterdHabits = self.arrGoals.filter { (entry) -> Bool in
            return Calendar.current.isDate(entry.date, inSameDayAs: selectedDate)
        }
        self.reloadData()
    }
    
    private func handleDataPopulation() {
        if self.isFromHabits {
            self.filterHabbits()
        } else {
            self.filterTaskByDate()
        }
    }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension TaskAndHabitCalenderVC: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.handleDataPopulation()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TaskAndHabitCalenderVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFromHabits ? self.arrFilterdHabits.count : self.fillterdTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskAndHabitsTableViewCell
        cell.tag = indexPath.row
        cell.parentVC = self
        cell.selectedDate = self.calendarView.selectedDate ?? Date()
        if self.isFromHabits {
            cell.modelHabit = self.arrFilterdHabits[indexPath.row]
        } else {
            cell.modelTask = self.fillterdTask[indexPath.row]
        }
        return cell
    }
}

