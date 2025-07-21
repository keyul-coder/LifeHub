//
//  TaskViewController.swift
//  LifeHub
//
//  Created by keyul patel on 6/2/25.
//

import UIKit
import UserNotifications

class TaskViewController: UIViewController, UITableViewDataSource,
    UITableViewDelegate, AddTaskDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calenderBarButton: UIBarButtonItem!

    // MARK: - Data source
    var tasks: [ToDoTask] = []
    var selectedTaskIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""

        tableView.dataSource = self
        tableView.delegate = self

        // Register a basic UITableViewCell if not done in storyboard
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "TaskCell"
        )

        // Load saved tasks
        loadTasksFromUserDefaults()

        // Ask for notification permissions here
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
        ]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "segueTaskAndHabitCalenderVC" {
            if let destinationVC = segue.destination as? TaskAndHabitCalenderVC {
                destinationVC.arrTasks = self.tasks
                destinationVC.isFromHabits = false
            }
        }
    }

    @IBAction func addTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddTask", bundle: nil)  // use AddTask.storyboard here
        if let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddTaskViewController"
        ) as? AddTaskViewController {
            addVC.delegate = self
            present(addVC, animated: true)
        }
    }
    
    @IBAction func onTapCalenderBarButton(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueTaskAndHabitCalenderVC", sender: nil)
    }

    // MARK: - AddTaskDelegate method
    func didAddTask(_ task: ToDoTask) {
        print("recivered task: \(task.title)")
        if let index = selectedTaskIndex {
            tasks[index] = task
            selectedTaskIndex = nil
        } else {
            tasks.append(task)
        }
        saveTasksToUserDefaults()
        tableView.reloadData()
        scheduleNotification(for: task)
    }

    // MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TaskCell",
            for: indexPath
        )
        let task = tasks[indexPath.row]

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: task.date)

        let completionIcon = task.isCompleted ? "✅" : "⭕"
        let completionStatus = task.isCompleted ? "Completed" : "Pending"
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
            \(completionIcon) \(task.title)
            🗓️ \(dateString)
            ⏫ \(task.priority)
            🔁 Recurring: \(task.isRecurring ? "Yes" : "No")
            📋 Status: \(completionStatus)
            """
        
        // Style completed tasks differently
        if task.isCompleted {
            cell.textLabel?.textColor = .systemGray
            cell.backgroundColor = .systemGray6
        } else {
            cell.textLabel?.textColor = .label
            cell.backgroundColor = .systemBackground
        }
        
        return cell
    }
    // MARK: - Edit on Tap
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let task = tasks[indexPath.row]
        selectedTaskIndex = indexPath.row

        let storyboard = UIStoryboard(name: "AddTask", bundle: nil)
        if let editVC = storyboard.instantiateViewController(
            withIdentifier: "AddTaskViewController"
        ) as? AddTaskViewController {
            editVC.delegate = self
            editVC.taskToEdit = task  // pass task for editing
            present(editVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Swipe Actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        
        // Complete/Incomplete action
        let completeAction = UIContextualAction(style: .normal, title: task.isCompleted ? "Mark Incomplete" : "Mark Complete") { [weak self] (action, view, completionHandler) in
            self?.tasks[indexPath.row].toggleCompletion()
            self?.saveTasksToUserDefaults()
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        completeAction.backgroundColor = task.isCompleted ? .systemOrange : .systemGreen
        completeAction.image = UIImage(systemName: task.isCompleted ? "xmark.circle" : "checkmark.circle")
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.tasks.remove(at: indexPath.row)
            self?.saveTasksToUserDefaults()
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        return configuration
    }
    
    // MARK: - UserDefaults Methods
    func saveTasksToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: "SavedTasks")
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
    
    func loadTasksFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "SavedTasks"),
           let savedTasks = try? JSONDecoder().decode([ToDoTask].self, from: data) {
            tasks = savedTasks
            tableView.reloadData()
        }
    }

    // MARK: - Schedule notification for task date/time
    func scheduleNotification(for task: ToDoTask) {
        let content = UNMutableNotificationContent()
        content.title = "📌 Reminder"
        content.body = task.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: task.date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: task.isRecurring
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔴 Notification error: \(error.localizedDescription)")
            } else {
                print(
                    "✅ Notification scheduled for \(task.title) at \(task.date)"
                )
            }
        }
    }
}
