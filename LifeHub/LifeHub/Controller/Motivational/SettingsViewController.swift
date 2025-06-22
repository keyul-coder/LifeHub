//
//  SettingsViewController.swift
//  LifeHub
//
//  Created by keyul patel on 6/20/25.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController {
    
   
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var notificationTimePicker: UIDatePicker!
    @IBOutlet weak var defaultCategorySegment: UISegmentedControl!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var exportFavoritesButton: UIButton!
    @IBOutlet weak var clearDataButton: UIButton!
    
    private let quoteManager = QuoteManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestNotificationPermission()
    }
    
    private func setupUI() {
        // Set initial values from UserDefaults
        notificationsSwitch.isOn = quoteManager.areNotificationsEnabled()
        notificationTimePicker.date = quoteManager.getNotificationTime()
        notificationTimePicker.isEnabled = notificationsSwitch.isOn
        
        let defaultCategory = quoteManager.getDefaultCategory()
        let categories = ["Motivation", "Success", "Happiness"]
        if let index = categories.firstIndex(of: defaultCategory) {
            defaultCategorySegment.selectedSegmentIndex = index
        }
        
        fontSizeSlider.value = Float(quoteManager.getFontSize())
        
        // Style buttons
        exportFavoritesButton.layer.cornerRadius = 8
        clearDataButton.layer.cornerRadius = 8
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func notificationsToggled(_ sender: UISwitch) {
        quoteManager.setNotificationsEnabled(sender.isOn)
        notificationTimePicker.isEnabled = sender.isOn
    }
    
    @IBAction func notificationTimeChanged(_ sender: UIDatePicker) {
        quoteManager.setNotificationTime(sender.date)
    }
    
    @IBAction func defaultCategoryChanged(_ sender: UISegmentedControl) {
        let categories = ["Motivation", "Success", "Happiness"]
        let selectedCategory = categories[sender.selectedSegmentIndex]
        quoteManager.setDefaultCategory(selectedCategory)
    }
    
    @IBAction func fontSizeChanged(_ sender: UISlider) {
        quoteManager.setFontSize(CGFloat(sender.value))
        
    }
    
    @IBAction func exportFavorites(_ sender: UIButton) {
        guard let fileURL = quoteManager.exportFavorites() else {
            showAlert(title: "Export Failed", message: "Could not export favorites.")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    @IBAction func clearAllData(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Clear All Data",
            message: "This will reset all settings and clear your favorites. This cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { _ in
            // Reset all settings
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            
            // Reload UI
            self.setupUI()
            
            // Show confirmation
            self.showAlert(title: "Success", message: "All data has been reset")
        }))
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
