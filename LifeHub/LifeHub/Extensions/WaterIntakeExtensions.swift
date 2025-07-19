//
//  WaterIntakeExtensions.swift
//  LifeHub
//
//  Created by Smit Patel on 19/07/25.
//

import Foundation
import CoreData

extension Array where Element == WaterIntake {
    
    /// Calculate total water intake for the day
    var totalIntake: Int {
        return self.reduce(0) { $0 + Int($1.amount) }
    }
    
    /// Calculate water intake percentage based on daily goal
    func intakePercentage(dailyGoal: Int = 2500) -> Int {
        let total = totalIntake
        let percentage = Int(Double(total) / Double(dailyGoal) * 100)
        return Swift.min(percentage, 100)
    }
    
    /// Get formatted intake string
    func formattedIntakeString(dailyGoal: Int = 2500) -> String {
        let total = totalIntake
        let percentage = intakePercentage(dailyGoal: dailyGoal)
        return "\(total)ml (\(percentage)%)"
    }
}

// MARK: - Water Intake Constants
struct WaterIntakeConstants {
    static let defaultDailyGoal = 2500 // ml
    static let glassSize = 250 // ml
    static let bottleSize = 500 // ml
}

// MARK: - Water Intake Helper
class WaterIntakeHelper {
    
    /// Get today's water intake records
    static func getTodaysIntake() -> [WaterIntake] {
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching water intake: \(error)")
            return []
        }
    }
    
    /// Get current water intake percentage
    static func getCurrentIntakePercentage() -> Int {
        let records = getTodaysIntake()
        return records.intakePercentage()
    }
    
    /// Get current total intake in ml
    static func getCurrentTotalIntake() -> Int {
        let records = getTodaysIntake()
        return records.totalIntake
    }
}
