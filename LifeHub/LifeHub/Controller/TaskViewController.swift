//
//  TaskViewController.swift
//  LifeHub
//
//  Created by keyul patel on 6/2/25.
//


import UIKit
import UserNotifications

class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddTaskDelegate {

   @IBOutlet weak var tableView: UITableView!

   // MARK: - Data source
   var tasks: [ToDoTask] = []
    var selectedTaskIndex: Int?

   override func viewDidLoad() {
       super.viewDidLoad()
       title = ""

       tableView.dataSource = self
       tableView.delegate = self

       // Register a basic UITableViewCell if not done in storyboard
       tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
       
       // Ask for notification permissions here
               UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                   if let error = error {
                       print("Notification permission error: \(error)")
                }
        }

   }
    

    @IBAction func addTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddTask", bundle: nil)  // use AddTask.storyboard here
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddTaskViewController") as? AddTaskViewController {
            addVC.delegate = self
            present(addVC, animated: true)
        }
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
       tableView.reloadData()
       scheduleNotification(for: task)
   }

   // MARK: - UITableViewDataSource methods
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tasks.count
   }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
            let task = tasks[indexPath.row]

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let dateString = formatter.string(from: task.date)

            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = """
            \(task.title)
            🗓️ \(dateString)
            ⏫ \(task.priority)
            🔁 Recurring: \(task.isRecurring ? "Yes" : "No")
            """
            return cell
        }
    // MARK: - Edit on Tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        selectedTaskIndex = indexPath.row

        let storyboard = UIStoryboard(name: "AddTask", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "AddTaskViewController") as? AddTaskViewController {
            editVC.delegate = self
            editVC.taskToEdit = task // pass task for editing
            present(editVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

   // MARK: - Enable swipe to delete
   func tableView(_ tableView: UITableView,
                  commit editingStyle: UITableViewCell.EditingStyle,
                  forRowAt indexPath: IndexPath) {
       if editingStyle == .delete {
           tasks.remove(at: indexPath.row)
           tableView.deleteRows(at: [indexPath], with: .fade)
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

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: task.isRecurring)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔴 Notification error: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(task.title) at \(task.date)")
            }
        }
   }
}
