//
//  settingVC.swift
//  LifeHub
//
//  Created by keyul patel on 19/7/25.
//
import UIKit
import UserNotifications

class SettingsVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔧 SettingsVC viewDidLoad called")
        setupUI()
        loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("👀 SettingsVC viewWillAppear called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("✨ SettingsVC viewDidAppear called")
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Settings"
        
        // Set version from bundle
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        } else {
            versionLabel.text = "Version 1.0.0"
        }
        
        // Load user profile first, then set defaults if needed
        loadUserProfile()
        
        // Set default user info if not loaded from UserDefaults
        if usernameLabel.text?.isEmpty ?? true {
            usernameLabel.text = "User Name"
        }
        if emailLabel.text?.isEmpty ?? true {
            emailLabel.text = "[email]"
        }
        
        print("✅ SettingsVC UI setup completed")
    }
    
    private func loadSettings() {
        // Load dark mode setting
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        darkModeSwitch.isOn = isDarkMode
        
        // Load notification setting
        let isNotificationsEnabled = UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
        notificationsSwitch.isOn = isNotificationsEnabled
    }
    
    // MARK: - IBActions
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkModeEnabled")
        
        if sender.isOn {
            // Enable dark mode
            if #available(iOS 13.0, *) {
                view.window?.overrideUserInterfaceStyle = .dark
            }
        } else {
            // Enable light mode
            if #available(iOS 13.0, *) {
                view.window?.overrideUserInterfaceStyle = .light
            }
        }
        
        // Show confirmation
        showAlert(title: "Dark Mode", message: sender.isOn ? "Dark mode enabled" : "Light mode enabled")
    }
    
    @IBAction func notificationsToggled(_ sender: UISwitch) {
        if sender.isOn {
            requestNotificationPermission()
        } else {
            UserDefaults.standard.set(false, forKey: "isNotificationsEnabled")
            showAlert(title: "Notifications", message: "Notifications disabled")
        }
    }
    
    @IBAction func exportDataTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Export Data", 
                                    message: "Would you like to export your LifeHub data?", 
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Export", style: .default) { _ in
            self.exportUserData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @IBAction func deleteAllDataTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete All Data", 
                                    message: "Are you sure you want to delete all your LifeHub data? This action cannot be undone.", 
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.confirmDeleteAllData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @IBAction func privacyPolicyTapped(_ sender: UIButton) {
        if let url = URL(string: "https://your-privacy-policy-url.com") {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Privacy Policy", message: "Privacy policy will be available soon.")
        }
    }
    
    @IBAction func termsOfServiceTapped(_ sender: UIButton) {
        if let url = URL(string: "https://your-terms-of-service-url.com") {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Terms of Service", message: "Terms of service will be available soon.")
        }
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
    
    // MARK: - Helper Methods
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    UserDefaults.standard.set(true, forKey: "isNotificationsEnabled")
                    self.showAlert(title: "Notifications", message: "Notifications enabled successfully!")
                } else {
                    self.notificationsSwitch.isOn = false
                    self.showAlert(title: "Notifications", message: "Please enable notifications in Settings app to receive reminders.")
                }
            }
        }
    }
    
    private func exportUserData() {
        // Create a simple text export of user data
        var exportData = "LifeHub Data Export\n"
        exportData += "Export Date: \(Date())\n\n"
        
        // Add user preferences
        exportData += "Settings:\n"
        exportData += "Dark Mode: \(UserDefaults.standard.bool(forKey: "isDarkModeEnabled") ? "Enabled" : "Disabled")\n"
        exportData += "Notifications: \(UserDefaults.standard.bool(forKey: "isNotificationsEnabled") ? "Enabled" : "Disabled")\n\n"
        
        // You can add more data here based on your app's data structure
        exportData += "Note: This is a basic export. Full data export functionality can be enhanced based on your specific data models.\n"
        
        // Create activity view controller to share the data
        let activityVC = UIActivityViewController(activityItems: [exportData], applicationActivities: nil)
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(activityVC, animated: true)
    }
    
    private func confirmDeleteAllData() {
        let finalAlert = UIAlertController(title: "Final Confirmation", 
                                         message: "This will permanently delete ALL your data. Are you absolutely sure?", 
                                         preferredStyle: .alert)
        
        finalAlert.addAction(UIAlertAction(title: "Yes, Delete Everything", style: .destructive) { _ in
            self.deleteAllUserData()
        })
        
        finalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(finalAlert, animated: true)
    }
    
    private func deleteAllUserData() {
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        
        // Clear Core Data (if you're using it)
        // You'll need to implement this based on your CoreDataStack
        // CoreDataStack.shared.deleteAllData()
        
        // Reset switches
        darkModeSwitch.isOn = false
        notificationsSwitch.isOn = false
        
        // Reset to light mode
        if #available(iOS 13.0, *) {
            view.window?.overrideUserInterfaceStyle = .light
        }
        
        showAlert(title: "Data Deleted", message: "All your data has been successfully deleted.") { _ in
            // Optionally navigate back to main screen or restart app
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
}

// MARK: - Extensions
extension SettingsVC {
    
    /// Update user profile information
    func updateUserProfile(name: String, email: String) {
        usernameLabel.text = name
        emailLabel.text = email
        
        // Save to UserDefaults
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
    }
    
    /// Load user profile from UserDefaults
    private func loadUserProfile() {
        if let name = UserDefaults.standard.string(forKey: "userName") {
            usernameLabel.text = name
        }
        
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            emailLabel.text = email
        }
    }
}
