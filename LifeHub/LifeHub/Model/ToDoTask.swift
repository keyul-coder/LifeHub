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
    var isCompleted: Bool
    
    mutating func toggleCompletion() {
        isCompleted.toggle()
    }
}
