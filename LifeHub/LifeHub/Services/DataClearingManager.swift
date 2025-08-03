//
//  DataClearingManager.swift
//  LifeHub
//
//  Created by Kiro AI on 8/2/25.
//

import Foundation
import CoreData

class DataClearingManager {
    static let shared = DataClearingManager()
    
    private init() {}
    
    // MARK: - Complete Data Clearing
    
    func clearAllAppData(includeFirebase: Bool = true, completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var clearingSuccess = true
        
        // Clear UserDefaults
        clearUserDefaults()
        
        // Clear Core Data
        clearCoreData()
        
        // Clear Local Data Managers
        clearLocalDataManagers()
        
        // Clear Firebase Data (if requested and user is authenticated)
        if includeFirebase && FirebaseManager.shared.isUserLoggedIn {
            group.enter()
            clearAllFirebaseData { success in
                if !success {
                    clearingSuccess = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Post notification that all data has been cleared
            NotificationCenter.default.post(name: .allDataCleared, object: nil)
            completion(clearingSuccess)
        }
    }
    
    // MARK: - Individual Clearing Methods
    
    private func clearUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        // Clear all keys except system ones
        let systemKeys = ["AppleLanguages", "AppleLocale", "NSLanguages"]
        
        dictionary.keys.forEach { key in
            if !systemKeys.contains(key) {
                defaults.removeObject(forKey: key)
            }
        }
        
        print("✅ UserDefaults cleared successfully")
    }
    
    private func clearCoreData() {
        CoreDataStack.shared.deleteAllData()
        print("✅ Core Data cleared successfully")
    }
    
    private func clearLocalDataManagers() {
        // Clear Tasks
        TaskManager.shared.saveTasks([])
        
        // Clear Wellness Diary
        WellnessDiaryModel.saveDiaryEntries([])
        
        // Clear Badges
        if let data = try? JSONEncoder().encode([String]()) {
            UserDefaults.standard.set(data, forKey: "earnedBadges")
        }
        
        // Clear Water Intake Manager
        WaterIntakeManager.shared.clearAllData()
    }
    
    private func clearAllFirebaseData(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var clearSuccess = true
        
        // Clear all Firebase collections with empty data
        let emptyTasks: [ToDoTask] = []
        let emptyWaterRecords: [WaterIntakeRecord] = []
        let emptyWellnessEntries: [WellnessDiaryModel] = []
        let emptyBadges: [String] = []
        let emptySettings: [String: Any] = [:]
        
        // Clear Tasks
        group.enter()
        FirebaseManager.shared.saveTasks(emptyTasks) { error in
            if error != nil {
                clearSuccess = false
                print("❌ Error clearing Firebase tasks: \(error?.localizedDescription ?? "Unknown error")")
            }
            group.leave()
        }
        
        // Clear Water Intake
        group.enter()
        FirebaseManager.shared.saveWaterIntake(emptyWaterRecords) { error in
            if error != nil {
                clearSuccess = false
                print("❌ Error clearing Firebase water intake: \(error?.localizedDescription ?? "Unknown error")")
            }
            group.leave()
        }
        
        // Clear Wellness Diary
        group.enter()
        FirebaseManager.shared.saveWellnessDiary(emptyWellnessEntries) { error in
            if error != nil {
                clearSuccess = false
                print("❌ Error clearing Firebase wellness diary: \(error?.localizedDescription ?? "Unknown error")")
            }
            group.leave()
        }
        
        // Clear Badges
        group.enter()
        FirebaseManager.shared.saveBadges(emptyBadges) { error in
            if error != nil {
                clearSuccess = false
                print("❌ Error clearing Firebase badges: \(error?.localizedDescription ?? "Unknown error")")
            }
            group.leave()
        }
        
        // Clear Streak Data
        group.enter()
        FirebaseManager.shared.saveStreakData(currentStreak: 0, longestStreak: 0, lastUpdate: nil) { error in
            if error != nil {
                clearSuccess = false
                print("❌ Error clearing Firebase streak data: \(error?.localizedDescription ?? "Unknown error")")
            }
            group.leave()
        }
        
        // Clear App Settings
        group.enter()
        FirebaseManager.shared.saveAppSettings(emptySettings) { error in
            if error != nil {
                clearSuccess = false
                print("❌ Error clearing Firebase app settings: \(error?.localizedDescription ?? "Unknown error")")
            }
            group.leave()
        }
        
        // Clear User Profile
        group.enter()
        
        
        group.notify(queue: .main) {
            if clearSuccess {
                print("✅ All Firebase data cleared successfully")
            } else {
                print("❌ Some Firebase data could not be cleared")
            }
            completion(clearSuccess)
        }
    }
    
    // MARK: - Specific Data Type Clearing
    
    func clearTasksOnly(completion: @escaping (Bool) -> Void) {
        TaskManager.shared.saveTasks([])
        
        if FirebaseManager.shared.isUserLoggedIn {
            FirebaseManager.shared.saveTasks([]) { error in
                completion(error == nil)
            }
        } else {
            completion(true)
        }
    }
    
    func clearWaterIntakeOnly(completion: @escaping (Bool) -> Void) {
        WaterIntakeManager.shared.clearAllData()
        
        if FirebaseManager.shared.isUserLoggedIn {
            FirebaseManager.shared.saveWaterIntake([]) { error in
                completion(error == nil)
            }
        } else {
            completion(true)
        }
    }
    
    func clearWellnessDiaryOnly(completion: @escaping (Bool) -> Void) {
        WellnessDiaryModel.saveDiaryEntries([])
        
        if FirebaseManager.shared.isUserLoggedIn {
            FirebaseManager.shared.saveWellnessDiary([]) { error in
                completion(error == nil)
            }
        } else {
            completion(true)
        }
    }
    
    func clearBadgesOnly(completion: @escaping (Bool) -> Void) {
        if let data = try? JSONEncoder().encode([String]()) {
            UserDefaults.standard.set(data, forKey: "earnedBadges")
        }
        
        if FirebaseManager.shared.isUserLoggedIn {
            FirebaseManager.shared.saveBadges([]) { error in
                completion(error == nil)
            }
        } else {
            completion(true)
        }
    }
    
    // MARK: - Reset to Default State
    
    func resetToDefaultState(completion: @escaping (Bool) -> Void) {
        clearAllAppData(includeFirebase: true) { [weak self] success in
            if success {
                self?.setDefaultSettings()
            }
            completion(success)
        }
    }
    
    private func setDefaultSettings() {
        // Set default app settings
        UserDefaults.standard.set(false, forKey: "isDarkModeEnabled")
        UserDefaults.standard.set(false, forKey: "isNotificationsEnabled")
        UserDefaults.standard.set(2500, forKey: "waterDailyGoal")
        UserDefaults.standard.set("User Name", forKey: "userName")
        UserDefaults.standard.set("[email]", forKey: "userEmail")
        
        print("✅ Default settings restored")
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let allDataCleared = Notification.Name("allDataCleared")
}
