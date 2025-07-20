//
//  ToDoTask.swift
//  LifeHub
//
//  Created by keyul patel on 6/5/25.


import Foundation

struct ToDoTask: Codable {
    var title: String
    var date: Date
    var priority: String
    var isRecurring: Bool
    var subtasks: String
    var isCompleted: Bool = false
    var completedDate: Date?
    
    // Helper method to mark task as completed
    mutating func markCompleted() {
        isCompleted = true
        completedDate = Date()
    }
    
    // Helper method to check if task was completed today
    func wasCompletedToday() -> Bool {
        guard let completedDate = completedDate else { return false }
        return Calendar.current.isDateInToday(completedDate)
    }
}

