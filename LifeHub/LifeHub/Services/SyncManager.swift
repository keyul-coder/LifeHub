//
//  SyncManager.swift
//  LifeHub
//
//  Created by Kiro AI on 8/2/25.
//

import Foundation
import UIKit

class SyncManager {
    static let shared = SyncManager()
    
    private var isSyncing = false
    private var lastSyncDate: Date?
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        // Sync data when app becomes active
        syncAllData { _ in }
    }
    
    @objc private func appWillResignActive() {
        // Ensure all data is synced before app goes to background
        syncAllDataToFirebase { _ in }
    }
    
    // MARK: - Authentication Management
    
    func ensureUserAuthenticated(completion: @escaping (Bool) -> Void) {
        if FirebaseManager.shared.isUserLoggedIn {
            completion(true)
        } else {
            FirebaseManager.shared.signInAnonymously { result in
                switch result {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Full Data Sync
    
    func syncAllData(completion: @escaping (Bool) -> Void) {
        guard !isSyncing else {
            completion(false)
            return
        }
        
        isSyncing = true
        
        ensureUserAuthenticated { [weak self] authenticated in
            guard authenticated else {
                self?.isSyncing = false
                completion(false)
                return
            }
            
            self?.performFullDataSync(completion: completion)
        }
    }
    
    private func performFullDataSync(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var syncResults: [Bool] = []
        
        // Sync Tasks
        group.enter()
        TaskManager.shared.syncFromFirebase { success in
            syncResults.append(success)
            group.leave()
        }
        
        // Sync Water Intake
        group.enter()
        WaterIntakeManager.shared.syncFromFirebase { success in
            syncResults.append(success)
            group.leave()
        }
        
        // Sync Wellness Diary
        group.enter()
        WellnessDiaryModel.syncFromFirebase { success in
            syncResults.append(success)
            group.leave()
        }
        
        // Sync Badges
        group.enter()
        BadgeManager.shared.syncFromFirebase { success in
            syncResults.append(success)
            group.leave()
        }
        
        // Sync Streak Data
        group.enter()
        syncStreakDataFromFirebase { success in
            syncResults.append(success)
            group.leave()
        }
        
        // Sync App Settings
        group.enter()
        syncAppSettingsFromFirebase { success in
            syncResults.append(success)
            group.leave()
        }
        

        
        group.notify(queue: .main) { [weak self] in
            self?.isSyncing = false
            self?.lastSyncDate = Date()
            
            let allSuccess = syncResults.allSatisfy { $0 }
            
            // Post notification
            NotificationCenter.default.post(
                name: .firebaseDataSynced,
                object: nil,
                userInfo: ["success": allSuccess]
            )
            
            completion(allSuccess)
        }
    }
    
    // MARK: - Upload All Data to Firebase
    
    func syncAllDataToFirebase(completion: @escaping (Error?) -> Void) {
        ensureUserAuthenticated { [weak self] authenticated in
            guard authenticated else {
                completion(NSError(domain: "SyncManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
                return
            }
            
            FirebaseManager.shared.syncAllDataToFirebase(completion: completion)
        }
    }
    
    // MARK: - Individual Sync Methods
    
    private func syncStreakDataFromFirebase(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.loadStreakData { result in
            switch result {
            case .success(let data):
                if let currentStreak = data["currentStreak"] as? Int {
                    UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
                }
                if let longestStreak = data["longestStreak"] as? Int {
                    UserDefaults.standard.set(longestStreak, forKey: "longestStreak")
                }
                if let lastUpdateTimestamp = data["lastStreakUpdate"] as? Timestamp {
                    UserDefaults.standard.set(lastUpdateTimestamp.dateValue(), forKey: "lastStreakUpdate")
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    private func syncAppSettingsFromFirebase(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.loadAppSettings { result in
            switch result {
            case .success(let settings):
                if let darkMode = settings["isDarkModeEnabled"] as? Bool {
                    UserDefaults.standard.set(darkMode, forKey: "isDarkModeEnabled")
                }
                if let notifications = settings["isNotificationsEnabled"] as? Bool {
                    UserDefaults.standard.set(notifications, forKey: "isNotificationsEnabled")
                }
                if let waterGoal = settings["waterDailyGoal"] as? Int {
                    UserDefaults.standard.set(waterGoal, forKey: "waterDailyGoal")
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
   
    
    // MARK: - Manual Sync Triggers
    
    func forceSyncToFirebase(completion: @escaping (Bool) -> Void) {
        syncAllDataToFirebase { error in
            completion(error == nil)
        }
    }
    
    func forceSyncFromFirebase(completion: @escaping (Bool) -> Void) {
        syncAllData(completion: completion)
    }
    
    // MARK: - Sync Status
    
    var isSyncInProgress: Bool {
        return isSyncing
    }
    
    var lastSyncTime: Date? {
        return lastSyncDate
    }
    
    func getSyncStatus() -> [String: Any] {
        return [
            "isSyncing": isSyncing,
            "lastSyncDate": lastSyncDate?.timeIntervalSince1970 ?? 0,
            "isAuthenticated": FirebaseManager.shared.isUserLoggedIn,
            "userID": FirebaseManager.shared.currentUserID ?? ""
        ]
    }
    
    // MARK: - Real-time Sync
    
    func enableRealtimeSync() {
        FirebaseManager.shared.enableRealtimeSync()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Import Extensions for Firebase Types

import FirebaseFirestore

extension Timestamp {
    // Helper for easier timestamp handling
}
