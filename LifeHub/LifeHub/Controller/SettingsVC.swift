//
//  SettingsVC.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-05-18.
//

import UIKit
import CoreData
import UniformTypeIdentifiers

class SettingsVC: UIViewController, UIDocumentPickerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
        setupAutoSync()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Set version label
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        }
    }
    
    private func loadSettings() {
        // Load dark mode setting
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        
        // Load notifications setting
        notificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
    }
    
    private func setupAutoSync() {
        // Setup automatic sync monitoring
        setupSyncStatusMonitoring()
    }
    
    // MARK: - Actions
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkModeEnabled")
        
        // Apply dark mode immediately
        if sender.isOn {
            view.window?.overrideUserInterfaceStyle = .dark
        } else {
            view.window?.overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func notificationsToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isNotificationsEnabled")
    }
    
    @IBAction func exportDataTapped(_ sender: UIButton) {
        exportData()
    }
    
    @IBAction func importDataTapped(_ sender: UIButton) {
        importData()
    }
    
    @IBAction func deleteDataTapped(_ sender: UIButton) {
        confirmDeleteAllData()
    }
    
    @IBAction func aboutTapped(_ sender: UIButton) {
        let aboutMessage = """
        LifeHub - Your Personal Life Management App
        
        LifeHub helps you track your daily activities, manage tasks, monitor water intake, and maintain a healthy lifestyle.
        
        Features:
        • Task Management
        • Water Intake Tracking
        • Wellness Diary
        • Goal Setting
        • Diet Tracking
        • Motivational Quotes
        
        Thank you for using LifeHub!
        """
        
        showAlert(title: "About LifeHub", message: aboutMessage)
    }
    
    // MARK: - Data Management
    private func exportData() {
        let tasks = TaskManager.shared.loadTasks()
        let waterRecords = WaterIntakeManager.shared.getAllRecords()
        let wellnessEntries = WellnessDiaryModel.loadDiaryEntries()
        let badges = BadgeManager.shared.getEarnedBadges()
        
        var exportData = "LIFEHUB DATA EXPORT\n"
        exportData += "Generated: \(Date())\n\n"
        
        // Tasks
        exportData += "TASKS (\(tasks.count)):\n"
        for task in tasks {
            exportData += "• \(task.title) - \(task.priority) - \(task.isCompleted ? "✓" : "○")\n"
        }
        exportData += "\n"
        
        // Water Records
        exportData += "WATER INTAKE (\(waterRecords.count) records):\n"
        let totalWater = waterRecords.reduce(0) { $0 + $1.amount }
        exportData += "Total: \(totalWater)ml\n\n"
        
        // Wellness Entries
        exportData += "WELLNESS DIARY (\(wellnessEntries.count) entries):\n"
        for entry in wellnessEntries.prefix(5) {
            exportData += "• \(entry.formattedDateString()): \(entry.text)\n"
        }
        exportData += "\n"
        
        // Badges
        exportData += "BADGES (\(badges.count)):\n"
        for badge in badges {
            exportData += "🏆 \(badge)\n"
        }
        
        // Create and present activity controller
        let activityController = UIActivityViewController(activityItems: [exportData], applicationActivities: nil)
        
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        
        present(activityController, animated: true)
    }
    
    private func importData() {
        let alert = UIAlertController(title: "Import Data", message: "Choose import source:", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "From File", style: .default) { _ in
            self.presentFilePicker()
        })
        
        alert.addAction(UIAlertAction(title: "From Firebase", style: .default) { _ in
            self.importFromFirebase()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func importFromFirebase() {
        // Check if user is authenticated
        if !FirebaseManager.shared.isUserLoggedIn {
            showAlert(title: "Authentication Required", message: "Please ensure you're connected to sync your data from Firebase.")
            return
        }
        
        // Show loading
        let loadingAlert = UIAlertController(title: "Importing from Firebase", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        // Perform import
        performFirebaseImport { [weak self] success, details in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        self?.showAlert(title: "Import Successful", message: "Data imported from Firebase successfully!\n\n\(details)")
                        
                        // Refresh UI
                        self?.loadSettings()
                    } else {
                        self?.showAlert(title: "Import Failed", message: "Failed to import data from Firebase.\n\nDetails:\n\(details)")
                    }
                }
            }
        }
    }
    
    private func performFirebaseImport(completion: @escaping (Bool, String) -> Void) {
        let group = DispatchGroup()
        var importResults: [String] = []
        var overallSuccess = true
        
        // Import Tasks
        group.enter()
        TaskManager.shared.syncFromFirebase { success in
            let taskCount = TaskManager.shared.loadTasks().count
            if success {
                importResults.append("✅ Tasks: \(taskCount) imported")
            } else {
                importResults.append("❌ Tasks: Import failed")
                overallSuccess = false
            }
            group.leave()
        }
        
        // Import Water Intake
        group.enter()
        WaterIntakeManager.shared.syncFromFirebase { success in
            let waterCount = WaterIntakeManager.shared.getAllRecords().count
            if success {
                importResults.append("✅ Water Records: \(waterCount) imported")
            } else {
                importResults.append("❌ Water Records: Import failed")
                overallSuccess = false
            }
            group.leave()
        }
        
        // Import Wellness Diary
        group.enter()
        WellnessDiaryModel.syncFromFirebase { success in
            let wellnessCount = WellnessDiaryModel.loadDiaryEntries().count
            if success {
                importResults.append("✅ Wellness Entries: \(wellnessCount) imported")
            } else {
                importResults.append("❌ Wellness Entries: Import failed")
                overallSuccess = false
            }
            group.leave()
        }
        
        // Import Badges
        group.enter()
        BadgeManager.shared.syncFromFirebase { success in
            let badgeCount = BadgeManager.shared.getEarnedBadges().count
            if success {
                importResults.append("✅ Badges: \(badgeCount) imported")
            } else {
                importResults.append("❌ Badges: Import failed")
                overallSuccess = false
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            let details = importResults.joined(separator: "\n")
            completion(overallSuccess, details)
        }
    }
    
    private func confirmDeleteAllData() {
        let alert = UIAlertController(
            title: "Delete All Data",
            message: "This will permanently delete all your app data including tasks, water records, wellness entries, and badges. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive) { _ in
            self.performDataDeletion()
        })
        
        present(alert, animated: true)
    }
    
    private func performDataDeletion() {
        DataClearingManager.shared.clearAllAppData(includeFirebase: true) { [weak self] (success: Bool) in
            DispatchQueue.main.async {
                if success {
                    self?.showAlert(title: "Data Deleted", message: "All app data has been successfully deleted.")
                    
                    // Reset UI to default state
                    self?.loadSettings()
                } else {
                    self?.showAlert(title: "Deletion Failed", message: "Some data could not be deleted. Please try again.")
                }
            }
        }
    }
    
    // MARK: - File Import
    private func presentFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json, .text])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        do {
            let data = try Data(contentsOf: url)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                processImportedData(jsonObject)
            } else {
                showAlert(title: "Import Error", message: "Invalid file format. Please select a valid JSON file.")
            }
        } catch {
            showAlert(title: "Import Error", message: "Failed to read file: \(error.localizedDescription)")
        }
    }
    
    private func processImportedData(_ data: [String: Any]) {
        // Process imported data here
        showAlert(title: "Import Successful", message: "Data has been imported successfully.")
        loadSettings()
    }
    
    // MARK: - Sync Status Monitoring
    private func setupSyncStatusMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(firebaseDataSynced(_:)),
            name: .firebaseDataSynced,
            object: nil
        )
    }
    
    @objc private func firebaseDataSynced(_ notification: Notification) {
        DispatchQueue.main.async {
            if let success = notification.userInfo?["success"] as? Bool {
                // Handle sync status if needed
            }
            
            if let imported = notification.userInfo?["imported"] as? Bool, imported {
                // Data was imported, refresh UI
                self.loadSettings()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}