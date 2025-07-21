//
//  TaskManager.swift
//  LifeHub
//
//  Created by Smit Patel on 20/07/25.
//

import Foundation

class TaskManager {
    static let shared = TaskManager()
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "savedTasks"
    private let dailyCompletionKey = "dailyTaskCompletion"
    
    private init() {}
    
    // MARK: - Task Management
    
    func saveTasks(_ tasks: [ToDoTask]) {
        if let data = try? JSONEncoder().encode(tasks) {
            userDefaults.set(data, forKey: tasksKey)
        }
    }
    
    func loadTasks() -> [ToDoTask] {
        guard let data = userDefaults.data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([ToDoTask].self, from: data) else {
            return []
        }
        return tasks
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
                        userDefaults.set(currentStreak + 1, forKey: "currentStreak")
                    } else {
                        // Gap in days - reset streak to 1
                        userDefaults.set(1, forKey: "currentStreak")
                    }
                    userDefaults.set(today, forKey: "lastStreakUpdate")
                }
            } else {
                // First time - start streak
                userDefaults.set(1, forKey: "currentStreak")
                userDefaults.set(today, forKey: "lastStreakUpdate")
            }
        }
    }
}
