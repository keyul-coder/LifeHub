//
//  WaterTrackingViewController.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-06-05.
//

import UIKit
import UserNotifications

class WaterTrackingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var waterProgressView: UIProgressView!
    @IBOutlet weak var waterLevelLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel! // Add this outlet in storyboard and connect it
    @IBOutlet weak var straksImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var reminderStackView: UIStackView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var setGoalButton: UIButton!
    
    // MARK: - Properties
    private var totalWaterIntake: Int = 0 {
        didSet {
            updateWaterDisplay()
            saveWaterIntake()
        }
    }
    
    private var dailyGoal: Int = 2000 {
        didSet {
            updateWaterDisplay()
            saveDailyGoal()
        }
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    private let goalKey = "dailyWaterGoal"
    private let intakeKey = "waterIntake"
    private let intakeHistoryKey = "waterIntakeHistory"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestNotificationPermission()
        loadDailyGoal()
        loadWaterIntake()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure buttons
        firstButton.setTitle("250ml", for: .normal)
        secondButton.setTitle("500ml", for: .normal)
        thirdButton.setTitle("1L", for: .normal)
        setGoalButton.setTitle("Set Daily Goal", for: .normal)
        
        // Style buttons
        [firstButton, secondButton, thirdButton, setGoalButton, saveButton].forEach { button in
            button?.layer.cornerRadius = 10
            button?.clipsToBounds = true
        }
        
        // Style progress view
        waterProgressView.layer.cornerRadius = 4
        waterProgressView.clipsToBounds = true
        
        // Configure date picker
        datePicker.minimumDate = Date()
        
        // Initialize display
        updateWaterDisplay()
    }
    
    // MARK: - Data Persistence
    private func loadDailyGoal() {
        dailyGoal = userDefaults.integer(forKey: goalKey) > 0 ? userDefaults.integer(forKey: goalKey) : 2000
    }
    
    private func saveDailyGoal() {
        userDefaults.set(dailyGoal, forKey: goalKey)
    }
    
    private func loadWaterIntake() {
        // Check if we have intake for today
        if let savedData = userDefaults.dictionary(forKey: intakeKey),
           let date = savedData["date"] as? Date,
           Calendar.current.isDateInToday(date) {
            totalWaterIntake = savedData["amount"] as? Int ?? 0
        } else {
            // Reset for new day
            totalWaterIntake = 0
        }
    }
    
    private func saveWaterIntake() {
        let data: [String: Any] = [
            "date": Date(),
            "amount": totalWaterIntake
        ]
        userDefaults.set(data, forKey: intakeKey)
    }
    
    private func saveToHistory() {
        let entry: [String: Any] = [
            "date": Date(),
            "amount": totalWaterIntake,
            "goal": dailyGoal
        ]
        
        var history = userDefaults.array(forKey: intakeHistoryKey) ?? []
        history.append(entry)
        userDefaults.set(history, forKey: intakeHistoryKey)
    }
    
    // MARK: - Notification Permission
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self?.reminderSwitch.isOn = false
                    self?.showAlert(title: "Notifications Disabled",
                                   message: "Enable notifications in Settings to use reminders")
                }
            }
        }
    }
    
    // MARK: - Goal Management
    @IBAction func setGoalButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Set Daily Water Goal",
            message: "Enter target in milliliters (mL)",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "e.g. 2000"
            textField.keyboardType = .numberPad
            textField.text = "\(self.dailyGoal)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text, let newGoal = Int(text), newGoal >= 500 {
                self.dailyGoal = newGoal
            } else {
                self.showAlert(title: "Invalid Input", message: "Please enter at least 500mL")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // MARK: - Water Tracking
    private func updateWaterDisplay() {
        let progress = min(Float(totalWaterIntake) / Float(dailyGoal), 1.0)
        waterProgressView.progress = progress
        
        let percentage = Int(progress * 100)
        goalLabel.text = "\(percentage)% of daily goal"
        
        waterLevelLabel.text = "\(totalWaterIntake)mL / \(dailyGoal)mL"
        
        // Update colors based on progress
        if totalWaterIntake >= dailyGoal {
            waterProgressView.tintColor = .systemGreen
            goalLabel.textColor = .systemGreen
        } else if percentage >= 50 {
            waterProgressView.tintColor = .systemBlue
            goalLabel.textColor = .systemBlue
        } else {
            waterProgressView.tintColor = .systemOrange
            goalLabel.textColor = .systemOrange
        }
    }
    
    @IBAction func waterAmountButtonTapped(_ sender: UIButton) {
        switch sender {
        case firstButton: totalWaterIntake += 250
        case secondButton: totalWaterIntake += 500
        case thirdButton: totalWaterIntake += 1000
        default: break
        }
    }
    
    // MARK: - Reminder Functions
    @IBAction func reminderSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            scheduleReminder()
        } else {
            cancelReminder()
        }
    }
    
    private func scheduleReminder() {
        let selectedDate = datePicker.date
        
        guard selectedDate > Date() else {
            showAlert(title: "Invalid Time", message: "Please select a future time")
            reminderSwitch.isOn = false
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "💧 Time to Hydrate!"
        content.body = "Don't forget to drink water! Goal: \(dailyGoal)mL"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: selectedDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: "waterReminder_\(selectedDate.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to set reminder")
                    self.reminderSwitch.isOn = false
                }
            }
        }
    }
    
    private func cancelReminder() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Save Function
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        saveToHistory()
        showAlert(title: "Saved", message: "Today's intake: \(totalWaterIntake)mL (\(Int(Float(totalWaterIntake) / Float(dailyGoal) * 100))% of goal)")
    }
    
    // MARK: - History Functionality
    func showHistory() {
        guard let history = userDefaults.array(forKey: intakeHistoryKey) as? [[String: Any]] else {
            showAlert(title: "History", message: "No history available yet")
            return
        }
        
        let historyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WaterHistoryViewController") as! WaterHistoryViewController
        historyVC.historyData = history
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - History View Controller
class WaterHistoryViewController: UITableViewController {
    var historyData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Water Intake History"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let entry = historyData.reversed()[indexPath.row]
        
        if let date = entry["date"] as? Date,
           let amount = entry["amount"] as? Int,
           let goal = entry["goal"] as? Int {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            let percentage = Int(Float(amount) / Float(goal) * 100)
            cell.textLabel?.text = "\(formatter.string(from: date)): \(amount)mL (\(percentage)% of \(goal)mL)"
        }
        
        return cell
    }
}
