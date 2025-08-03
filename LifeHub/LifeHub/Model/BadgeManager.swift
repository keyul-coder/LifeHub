//
//  BadgeManager.swift
//  LifeHub
//
//  Created by Kiro AI on 8/2/25.
//

import Foundation
import CoreData

class BadgeManager {
    static let shared = BadgeManager()
    
    private init() {}
    
    // MARK: - Badge Types
    
    enum BadgeType {
        case streak(days: Int)
        case dailyTasks(count: Int)
        case waterIntake(amount: Int)
        case wellness(entries: Int)
        case consistency(weeks: Int)
        case special(name: String)
    }
    
    // MARK: - Badge Checking
    
    func checkAllBadges() {
        checkStreakBadges()
        checkDailyTaskBadges()
        checkWaterIntakeBadges()
        checkWellnessBadges()
        checkConsistencyBadges()
        checkSpecialBadges()
    }
    
    private func checkStreakBadges() {
        let currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        let streakMilestones = [1, 3, 7, 14, 30, 50, 75, 100, 200, 365]
        
        for milestone in streakMilestones {
            if currentStreak >= milestone {
                let badgeName = getStreakBadgeName(for: milestone)
                unlockBadge(name: badgeName, type: .streak(days: milestone))
            }
        }
    }
    
    private func checkDailyTaskBadges() {
        let todayTasksCompleted = TaskManager.shared.getTodaysCompletedTasksCount()
        
        if todayTasksCompleted >= 1 {
            unlockBadge(name: "Task Starter", type: .dailyTasks(count: 1))
        }
        if todayTasksCompleted >= 3 {
            unlockBadge(name: "Daily Champion", type: .dailyTasks(count: 3))
        }
        if todayTasksCompleted >= 5 {
            unlockBadge(name: "Productivity Master", type: .dailyTasks(count: 5))
        }
        if todayTasksCompleted >= 10 {
            unlockBadge(name: "Task Warrior", type: .dailyTasks(count: 10))
        }
    }
    
    private func checkWaterIntakeBadges() {
        let todayWaterIntake = getCurrentWaterIntake()
        
        if todayWaterIntake >= 1000 {
            unlockBadge(name: "Hydration Start", type: .waterIntake(amount: 1000))
        }
        if todayWaterIntake >= 2000 {
            unlockBadge(name: "Well Hydrated", type: .waterIntake(amount: 2000))
        }
        if todayWaterIntake >= 2500 {
            unlockBadge(name: "Hydration Hero", type: .waterIntake(amount: 2500))
        }
        if todayWaterIntake >= 3000 {
            unlockBadge(name: "Water Champion", type: .waterIntake(amount: 3000))
        }
    }
    
    private func checkWellnessBadges() {
        let todayWellnessEntries = getTodaysWellnessEntries()
        let totalWellnessEntries = WellnessDiaryModel.loadDiaryEntries().count
        
        if todayWellnessEntries >= 1 {
            unlockBadge(name: "Mindful Moment", type: .wellness(entries: 1))
        }
        if totalWellnessEntries >= 7 {
            unlockBadge(name: "Wellness Week", type: .wellness(entries: 7))
        }
        if totalWellnessEntries >= 30 {
            unlockBadge(name: "Mindful Month", type: .wellness(entries: 30))
        }
        if totalWellnessEntries >= 100 {
            unlockBadge(name: "Wellness Guru", type: .wellness(entries: 100))
        }
    }
    
    private func checkConsistencyBadges() {
        let weeklyProgress = TaskManager.shared.getWeeklyProgress()
        let consistentDays = weeklyProgress.filter { $0 > 0 }.count
        
        if consistentDays >= 3 {
            unlockBadge(name: "Consistent Starter", type: .consistency(weeks: 1))
        }
        if consistentDays >= 5 {
            unlockBadge(name: "Weekly Warrior", type: .consistency(weeks: 1))
        }
        if consistentDays == 7 {
            unlockBadge(name: "Perfect Week", type: .consistency(weeks: 1))
        }
    }
    
    private func checkSpecialBadges() {
        let currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        let longestStreak = TaskManager.shared.getLongestStreak()
        let todayTasks = TaskManager.shared.getTodaysCompletedTasksCount()
        let todayWater = getCurrentWaterIntake()
        let todayWellness = getTodaysWellnessEntries()
        
        // Perfect Day Badge
        if todayTasks >= 3 && todayWater >= 2500 && todayWellness >= 1 {
            unlockBadge(name: "Perfect Day", type: .special(name: "Perfect Day"))
        }
        
        // Comeback Badge
        if currentStreak >= 7 && longestStreak > currentStreak {
            unlockBadge(name: "Comeback Kid", type: .special(name: "Comeback Kid"))
        }
        
        // Early Bird Badge (if task completed before 9 AM)
        let tasks = TaskManager.shared.loadTasks()
        let todayCompletedTasks = tasks.filter { task in
            guard let completedDate = task.completedDate else { return false }
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: completedDate)
            return calendar.isDateInToday(completedDate) && hour < 9
        }
        
        if !todayCompletedTasks.isEmpty {
            unlockBadge(name: "Early Bird", type: .special(name: "Early Bird"))
        }
    }
    
    // MARK: - Badge Management
    
    private func unlockBadge(name: String, type: BadgeType) {
        var earnedBadges = getEarnedBadges()
        
        if !earnedBadges.contains(name) {
            earnedBadges.append(name)
            saveEarnedBadges(earnedBadges)
            
            // Post notification
            NotificationCenter.default.post(
                name: .badgeEarned,
                object: nil,
                userInfo: [
                    "badgeName": name,
                    "badgeType": type
                ]
            )
            

        }
    }
    
    func getEarnedBadges() -> [String] {
        if let data = UserDefaults.standard.data(forKey: "earnedBadges"),
           let badges = try? JSONDecoder().decode([String].self, from: data) {
            return badges
        }
        return []
    }
    
    private func saveEarnedBadges(_ badges: [String]) {
        // Save locally
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: "earnedBadges")
        }
        
        // Sync to Firebase
        FirebaseManager.shared.saveBadges(badges) { _ in }
    }
    
    func isBadgeEarned(_ name: String) -> Bool {
        return getEarnedBadges().contains(name)
    }
    
    func getEarnedBadgeCount() -> Int {
        return getEarnedBadges().count
    }
    
    // MARK: - Helper Methods
    
    private func getStreakBadgeName(for days: Int) -> String {
        switch days {
        case 1: return "First Step"
        case 3: return "Getting Started"
        case 7: return "One Week"
        case 14: return "Two Weeks"
        case 30: return "One Month"
        case 50: return "Streak Master"
        case 75: return "Dedication"
        case 100: return "Century"
        case 200: return "Legendary"
        case 365: return "Ultimate"
        default: return "Streak \(days)"
        }
    }
    
    private func getCurrentWaterIntake() -> Int {
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let records = try context.fetch(request)
            return records.reduce(0) { $0 + Int($1.amount) }
        } catch {
            return 0
        }
    }
    
    private func getTodaysWellnessEntries() -> Int {
        let entries = WellnessDiaryModel.loadDiaryEntries()
        let today = Date()
        let todayEntries = entries.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
        return todayEntries.count
    }
    
    // MARK: - Badge Statistics
    
    func getBadgeStatistics() -> [String: Any] {
        let earnedCount = getEarnedBadgeCount()
        let currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        let longestStreak = TaskManager.shared.getLongestStreak()
        let todayTasks = TaskManager.shared.getTodaysCompletedTasksCount()
        let todayWater = getCurrentWaterIntake()
        let todayWellness = getTodaysWellnessEntries()
        
        return [
            "earnedBadges": earnedCount,
            "currentStreak": currentStreak,
            "longestStreak": longestStreak,
            "todayTasks": todayTasks,
            "todayWater": todayWater,
            "todayWellness": todayWellness
        ]
    }
    
    // MARK: - Firebase Integration
    
    func syncFromFirebase(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.loadBadges { result in
            switch result {
            case .success(let badges):
                // Save to local storage
                if let data = try? JSONEncoder().encode(badges) {
                    UserDefaults.standard.set(data, forKey: "earnedBadges")
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
}