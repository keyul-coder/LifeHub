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
        loadTasks()

        // Ask for notification permissions here
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
        ]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload tasks when returning to this view
        loadTasks()
        tableView.reloadData()
    }
    
    private func loadTasks() {
        tasks = TaskManager.shared.loadTasks()
    }
    
    private func saveTasks() {
        TaskManager.shared.saveTasks(tasks)
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
        saveTasks()
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

        cell.textLabel?.numberOfLines = 0
        
        // Add completion status to display
        let completionStatus = task.isCompleted ? "✅ Completed" : "⏳ Pending"
        
        cell.textLabel?.text = """
            \(task.title)
            🗓️ \(dateString)
            ⏫ \(task.priority)
            🔁 Recurring: \(task.isRecurring ? "Yes" : "No")
            \(completionStatus)
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

    // MARK: - Enable swipe actions
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            saveTasks()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        
        if task.isCompleted {
            // Mark as incomplete action
            let incompleteAction = UIContextualAction(style: .normal, title: "Mark Incomplete") { [weak self] (_, _, completionHandler) in
                self?.markTaskIncomplete(at: indexPath.row)
                completionHandler(true)
            }
            incompleteAction.backgroundColor = .systemOrange
            return UISwipeActionsConfiguration(actions: [incompleteAction])
        } else {
            // Mark as complete action
            let completeAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] (_, _, completionHandler) in
                self?.markTaskComplete(at: indexPath.row)
                completionHandler(true)
            }
            completeAction.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [completeAction])
        }
    }
    
    private func markTaskComplete(at index: Int) {
        guard index < tasks.count else { return }
        tasks[index].markCompleted()
        saveTasks()
        
        // Update streak and badge system
        TaskManager.shared.updateStreakIfNeeded()
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        // Show completion feedback
        let alert = UIAlertController(title: "Task Completed! 🎉", message: "Great job completing '\(tasks[index].title)'", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        present(alert, animated: true)
    }
    
    private func markTaskIncomplete(at index: Int) {
        guard index < tasks.count else { return }
        tasks[index].isCompleted = false
        tasks[index].completedDate = nil
        saveTasks()
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
