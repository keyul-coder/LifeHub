//
//  FirebaseManager.swift
//  LifeHub
//
//  Created by Kiro AI on 8/2/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let realtimeDB = Database.database().reference()
    
    private init() {}
    
    // MARK: - Authentication
    
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    // MARK: - User Management
    
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user.uid))
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    

    
    // MARK: - Tasks
    
    func saveTasks(_ tasks: [ToDoTask], completion: @escaping (Error?) -> Void) {
        guard let userID = currentUserID else {
            completion(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let tasksData = tasks.map { task in
            return [
                "title": task.title,
                "date": Timestamp(date: task.date),
                "priority": task.priority,
                "isRecurring": task.isRecurring,
                "subtasks": task.subtasks,
                "isCompleted": task.isCompleted,
                "completedDate": task.completedDate != nil ? Timestamp(date: task.completedDate!) : NSNull()
            ]
        }
        
        db.collection("users").document(userID).collection("tasks").document("userTasks").setData([
            "tasks": tasksData,
            "lastUpdated": FieldValue.serverTimestamp()
        ]) { error in
            completion(error)
        }
    }
    
    func loadTasks(completion: @escaping (Result<[ToDoTask], Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userID).collection("tasks").document("userTasks").getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists,
                      let data = document.data(),
                      let tasksArray = data["tasks"] as? [[String: Any]] {
                
                var tasks: [ToDoTask] = []
                for taskData in tasksArray {
                    if let title = taskData["title"] as? String,
                       let dateTimestamp = taskData["date"] as? Timestamp,
                       let priority = taskData["priority"] as? String,
                       let isRecurring = taskData["isRecurring"] as? Bool,
                       let subtasks = taskData["subtasks"] as? String,
                       let isCompleted = taskData["isCompleted"] as? Bool {
                        
                        var task = ToDoTask(title: title, date: dateTimestamp.dateValue(), priority: priority, isRecurring: isRecurring, subtasks: subtasks)
                        task.isCompleted = isCompleted
                        
                        if let completedTimestamp = taskData["completedDate"] as? Timestamp {
                            task.completedDate = completedTimestamp.dateValue()
                        }
                        
                        tasks.append(task)
                    }
                }
                completion(.success(tasks))
            } else {
                completion(.success([]))
            }
        }
    }
    
    // MARK: - Water Intake
    
    func saveWaterIntake(_ records: [WaterIntakeRecord], completion: @escaping (Error?) -> Void) {
        guard let userID = currentUserID else {
            completion(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let recordsData = records.map { record in
            return [
                "amount": record.amount,
                "timestamp": Timestamp(date: record.timestamp)
            ]
        }
        
        db.collection("users").document(userID).collection("waterIntake").document("records").setData([
            "records": recordsData,
            "lastUpdated": FieldValue.serverTimestamp()
        ]) { error in
            completion(error)
        }
    }
    
    func loadWaterIntake(completion: @escaping (Result<[WaterIntakeRecord], Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userID).collection("waterIntake").document("records").getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists,
                      let data = document.data(),
                      let recordsArray = data["records"] as? [[String: Any]] {
                
                var records: [WaterIntakeRecord] = []
                for recordData in recordsArray {
                    if let amount = recordData["amount"] as? Int,
                       let timestamp = recordData["timestamp"] as? Timestamp {
                        records.append(WaterIntakeRecord(amount: amount, timestamp: timestamp.dateValue()))
                    }
                }
                completion(.success(records))
            } else {
                completion(.success([]))
            }
        }
    }
    
    // MARK: - Wellness Diary
    
    func saveWellnessDiary(_ entries: [WellnessDiaryModel], completion: @escaping (Error?) -> Void) {
        guard let userID = currentUserID else {
            completion(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let entriesData = entries.map { entry in
            return [
                "id": entry.id,
                "text": entry.text,
                "date": Timestamp(date: entry.date)
            ]
        }
        
        db.collection("users").document(userID).collection("wellness").document("diary").setData([
            "entries": entriesData,
            "lastUpdated": FieldValue.serverTimestamp()
        ]) { error in
            completion(error)
        }
    }
    
    func loadWellnessDiary(completion: @escaping (Result<[WellnessDiaryModel], Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userID).collection("wellness").document("diary").getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists,
                      let data = document.data(),
                      let entriesArray = data["entries"] as? [[String: Any]] {
                
                var entries: [WellnessDiaryModel] = []
                for entryData in entriesArray {
                    if let id = entryData["id"] as? String,
                       let text = entryData["text"] as? String,
                       let timestamp = entryData["date"] as? Timestamp {
                        let entry = WellnessDiaryModel(text: text, date: timestamp.dateValue())
                        entry.id = id
                        entries.append(entry)
                    }
                }
                completion(.success(entries))
            } else {
                completion(.success([]))
            }
        }
    }
    
    // MARK: - Badges and Achievements
    
    func saveBadges(_ badges: [String], completion: @escaping (Error?) -> Void) {
        guard let userID = currentUserID else {
            completion(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        db.collection("users").document(userID).collection("achievements").document("badges").setData([
            "earnedBadges": badges,
            "lastUpdated": FieldValue.serverTimestamp()
        ]) { error in
            completion(error)
        }
    }
    
    func loadBadges(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userID).collection("achievements").document("badges").getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists,
                      let data = document.data(),
                      let badges = data["earnedBadges"] as? [String] {
                completion(.success(badges))
            } else {
                completion(.success([]))
            }
        }
    }
    
    // MARK: - Streak Data
    
    func saveStreakData(currentStreak: Int, longestStreak: Int, lastUpdate: Date?, completion: @escaping (Error?) -> Void) {
        guard let userID = currentUserID else {
            completion(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        var streakData: [String: Any] = [
            "currentStreak": currentStreak,
            "longestStreak": longestStreak,
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        if let lastUpdate = lastUpdate {
            streakData["lastStreakUpdate"] = Timestamp(date: lastUpdate)
        }
        
        db.collection("users").document(userID).collection("achievements").document("streaks").setData(streakData) { error in
            completion(error)
        }
    }
    
    func loadStreakData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userID).collection("achievements").document("streaks").getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                completion(.success(document.data() ?? [:]))
            } else {
                completion(.success([:]))
            }
        }
    }
    
    // MARK: - App Settings
    
    func saveAppSettings(_ settings: [String: Any], completion: @escaping (Error?) -> Void) {
        guard let userID = currentUserID else {
            completion(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        var settingsData = settings
        settingsData["lastUpdated"] = FieldValue.serverTimestamp()
        
        db.collection("users").document(userID).collection("settings").document("appSettings").setData(settingsData) { error in
            completion(error)
        }
    }
    
    func loadAppSettings(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userID).collection("settings").document("appSettings").getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                completion(.success(document.data() ?? [:]))
            } else {
                completion(.success([:]))
            }
        }
    }
    

    
    // MARK: - Real-time Sync
    
    func enableRealtimeSync() {
        guard let userID = currentUserID else { return }
        
        // Listen for tasks changes
        db.collection("users").document(userID).collection("tasks").document("userTasks")
            .addSnapshotListener { documentSnapshot, error in
                if error == nil {
                    NotificationCenter.default.post(name: .firebaseTasksUpdated, object: nil)
                }
            }
        
        // Listen for badges changes
        db.collection("users").document(userID).collection("achievements").document("badges")
            .addSnapshotListener { documentSnapshot, error in
                if error == nil {
                    NotificationCenter.default.post(name: .firebaseBadgesUpdated, object: nil)
                }
            }
    }
    
    // MARK: - Batch Operations
    
    func syncAllDataToFirebase(completion: @escaping (Error?) -> Void) {
        guard isUserLoggedIn else {
            signInAnonymously { result in
                switch result {
                case .success(_):
                    self.performFullSync(completion: completion)
                case .failure(let error):
                    completion(error)
                }
            }
            return
        }
        
        performFullSync(completion: completion)
    }
    
    private func performFullSync(completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var syncError: Error?
        
        // Sync Tasks
        group.enter()
        let tasks = TaskManager.shared.loadTasks()
        saveTasks(tasks) { error in
            if let error = error {
                syncError = error
            }
            group.leave()
        }
        
        // Sync Water Intake
        group.enter()
        let waterRecords = WaterIntakeManager.shared.getAllRecords()
        saveWaterIntake(waterRecords) { error in
            if let error = error {
                syncError = error
            }
            group.leave()
        }
        
        // Sync Wellness Diary
        group.enter()
        let wellnessEntries = WellnessDiaryModel.loadDiaryEntries()
        saveWellnessDiary(wellnessEntries) { error in
            if let error = error {
                syncError = error
            }
            group.leave()
        }
        
        // Sync Badges
        group.enter()
        let badges = BadgeManager.shared.getEarnedBadges()
        saveBadges(badges) { error in
            if let error = error {
                syncError = error
            }
            group.leave()
        }
        
        // Sync Streak Data
        group.enter()
        let currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        let longestStreak = TaskManager.shared.getLongestStreak()
        let lastUpdate = UserDefaults.standard.object(forKey: "lastStreakUpdate") as? Date
        saveStreakData(currentStreak: currentStreak, longestStreak: longestStreak, lastUpdate: lastUpdate) { error in
            if let error = error {
                syncError = error
            }
            group.leave()
        }
        
        // Sync App Settings
        group.enter()
        let settings: [String: Any] = [
            "isDarkModeEnabled": UserDefaults.standard.bool(forKey: "isDarkModeEnabled"),
            "isNotificationsEnabled": UserDefaults.standard.bool(forKey: "isNotificationsEnabled"),
            "waterDailyGoal": UserDefaults.standard.integer(forKey: "waterDailyGoal")
        ]
        saveAppSettings(settings) { error in
            if let error = error {
                syncError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(syncError)
        }
    }
}

// MARK: - Helper Models

struct WaterIntakeRecord {
    let amount: Int
    let timestamp: Date
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let firebaseTasksUpdated = Notification.Name("firebaseTasksUpdated")
    static let firebaseBadgesUpdated = Notification.Name("firebaseBadgesUpdated")
    static let firebaseDataSynced = Notification.Name("firebaseDataSynced")
}