//
//  TaskManager.swift
//  LifeHub
//
//  Created by Smit Patel on 20/07/25.
//

import Foundation

extension Notification.Name {
    static let streakUpdated = Notification.Name("streakUpdated")
    static let taskCompleted = Notification.Name("taskCompleted")
    static let badgeEarned = Notification.Name("badgeEarned")
}

class TaskManager {
    static let shared = TaskManager()
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "savedTasks"
    private let dailyCompletionKey = "dailyTaskCompletion"
    
    private init() {}
    
    // MARK: - Task Management
    
    func saveTasks(_ tasks: [ToDoTask]) {
        // Save locally
        if let data = try? JSONEncoder().encode(tasks) {
            userDefaults.set(data, forKey: tasksKey)
        }
        
        // Sync to Firebase
        syncToFirebase()
    }
    
    func loadTasks() -> [ToDoTask] {
        guard let data = userDefaults.data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([ToDoTask].self, from: data) else {
            return []
        }
        return tasks
    }
    
    // MARK: - Firebase Integration
    
    func syncToFirebase() {
        let tasks = loadTasks()
        FirebaseManager.shared.saveTasks(tasks) { _ in }
    }
    
    func syncFromFirebase(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.loadTasks { result in
            switch result {
            case .success(let tasks):
                // Save to local storage
                if let data = try? JSONEncoder().encode(tasks) {
                    self.userDefaults.set(data, forKey: self.tasksKey)
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    // MARK: - Daily Completion Tracking
    
    func getTodaysCompletedTasksCount() -> Int {
        let tasks = loadTasks()
        return tasks.filter { $0.wasCompletedToday() }.count
    }
    
    func markTaskCompleted(at index: Int) {
        var tasks = loadTasks()
        guard index < tasks.count else { return }
        
        tasks[index].markCompleted()
        saveTasks(tasks)
        
        // Update daily completion count
        updateDailyCompletionCount()
        
        // Update streak and post notification
        updateStreakIfNeeded()
        NotificationCenter.default.post(name: .taskCompleted, object: nil, userInfo: ["taskIndex": index])
    }
    
    private func updateDailyCompletionCount() {
        let todayString = getTodayString()
        let currentCount = getTodaysCompletedTasksCount()
        
        var dailyCompletions = getDailyCompletions()
        dailyCompletions[todayString] = currentCount
        
        if let data = try? JSONEncoder().encode(dailyCompletions) {
            userDefaults.set(data, forKey: dailyCompletionKey)
        }
    }
    
    private func getDailyCompletions() -> [String: Int] {
        guard let data = userDefaults.data(forKey: dailyCompletionKey),
              let completions = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return completions
    }
    
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Streak Management Integration
    
    func updateStreakIfNeeded() {
        let todayCount = getTodaysCompletedTasksCount()
        
        // If user completed at least one task today, maintain/increment streak
        if todayCount > 0 {
            let lastStreakUpdate = userDefaults.object(forKey: "lastStreakUpdate") as? Date
            let today = Date()
            
            // Check if we haven't updated streak today
            if let lastUpdate = lastStreakUpdate {
                if !Calendar.current.isDate(lastUpdate, inSameDayAs: today) {
                    // Check if it's consecutive day
                    if Calendar.current.isDate(lastUpdate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: today)!) {
                        // Consecutive day - increment streak
                        let currentStreak = userDefaults.integer(forKey: "currentStreak")
                        let newStreak = currentStreak + 1
                        userDefaults.set(newStreak, forKey: "currentStreak")
                        
                        // Update longest streak if needed
                        let longestStreak = userDefaults.integer(forKey: "longestStreak")
                        if newStreak > longestStreak {
                            userDefaults.set(newStreak, forKey: "longestStreak")
                        }
                        
                        // Post notification for badge system
                        NotificationCenter.default.post(name: .streakUpdated, object: nil, userInfo: ["newStreak": newStreak])
                    } else {
                        // Gap in days - reset streak to 1
                        userDefaults.set(1, forKey: "currentStreak")
                        NotificationCenter.default.post(name: .streakUpdated, object: nil, userInfo: ["newStreak": 1])
                    }
                    userDefaults.set(today, forKey: "lastStreakUpdate")
                    
                    // Sync streak data to Firebase
                    syncStreakToFirebase()
                }
            } else {
                // First time - start streak
                userDefaults.set(1, forKey: "currentStreak")
                userDefaults.set(today, forKey: "lastStreakUpdate")
                NotificationCenter.default.post(name: .streakUpdated, object: nil, userInfo: ["newStreak": 1])
                
                // Sync streak data to Firebase
                syncStreakToFirebase()
            }
        }
    }
    
    private func syncStreakToFirebase() {
        let currentStreak = userDefaults.integer(forKey: "currentStreak")
        let longestStreak = getLongestStreak()
        let lastUpdate = userDefaults.object(forKey: "lastStreakUpdate") as? Date
        
        FirebaseManager.shared.saveStreakData(currentStreak: currentStreak, longestStreak: longestStreak, lastUpdate: lastUpdate) { _ in }
    }
    
    // MARK: - Streak Analytics
    
    func getCurrentStreak() -> Int {
        return userDefaults.integer(forKey: "currentStreak")
    }
    
    func getLongestStreak() -> Int {
        let currentStreak = getCurrentStreak()
        let longestStreak = userDefaults.integer(forKey: "longestStreak")
        
        if currentStreak > longestStreak {
            userDefaults.set(currentStreak, forKey: "longestStreak")
            return currentStreak
        }
        
        return longestStreak
    }
    
    func getStreakHistory() -> [String: Int] {
        guard let data = userDefaults.data(forKey: dailyCompletionKey),
              let completions = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return completions
    }
    
    func getWeeklyProgress() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var weeklyProgress: [Int] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateString = getTodayString(for: date)
                let completions = getDailyCompletions()
                weeklyProgress.append(completions[dateString] ?? 0)
            }
        }
        
        return weeklyProgress.reversed()
    }
    
    private func getTodayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
