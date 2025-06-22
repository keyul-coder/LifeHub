//
//  AddTaskViewController.swift
//  LifeHub
//
//  Created by keyul patel on 6/3/25.
//

import UIKit
import UserNotifications

// MARK: - Delegate Protocol
protocol AddTaskDelegate: AnyObject {
    func didAddTask(_ task: ToDoTask)
}

class AddTaskViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var subtasksField: UITextField!
    @IBOutlet weak var recurringSwitch: UISwitch!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!

    // MARK: - Properties
    weak var delegate: AddTaskDelegate?

    var isEditingTask: Bool = false
    var taskToEdit: ToDoTask?

    private var selectedDate: Date = Date()
    private var selectedPriority: String = "No Priority"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup editing state
        if isEditingTask, let task = taskToEdit {
            taskNameField.text = task.title
            subtasksField.text = task.subtasks
            recurringSwitch.isOn = task.isRecurring
            selectedDate = task.date
            selectedPriority = task.priority
        }

        updateDateButtonTitle(date: selectedDate)
        priorityButton.setTitle(selectedPriority, for: .normal)
    }

    // MARK: - Actions

    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        guard let title = taskNameField.text, !title.isEmpty else {
            print("Title is empty")
            return
        }

     
        let subtasks = subtasksField.text ?? ""
        let isRecurring = recurringSwitch.isOn
        let priority = selectedPriority

        let task = ToDoTask(
            title: title,
            date: selectedDate,
            priority: priority,
            isRecurring: isRecurring,
     
            subtasks: subtasks
        )

        print(isEditingTask ? "Updating Task: \(task)" : "Adding Task: \(task)")

        // 🔔 Schedule Notification
        scheduleNotification(for: task)

        // Send to delegate
        delegate?.didAddTask(task)
        dismiss(animated: true)
    }

    @IBAction func showDateTimePicker(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Date & Time", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 10, y: 30, width: 300, height: 200)
        datePicker.date = selectedDate

        alert.view.addSubview(datePicker)

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            self.selectedDate = datePicker.date
            self.updateDateButtonTitle(date: self.selectedDate)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    @IBAction func showPriorityPicker(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Priority", message: nil, preferredStyle: .actionSheet)
        ["High", "Medium", "Low", "No Priority"].forEach { level in
            alert.addAction(UIAlertAction(title: level, style: .default) { _ in
                self.selectedPriority = level
                sender.setTitle(level, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func toggleRecurring(_ sender: UISwitch) {
        print("Recurring Task:", sender.isOn)
    }

    // MARK: - Helpers

    private func updateDateButtonTitle(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
        dateButton.setTitle(dateString, for: .normal)
    }

    private func scheduleNotification(for task: ToDoTask) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Reminder for task: \(task.title)"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: task.isRecurring)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for task: \(task.title)")
            }
        }
    }
}
