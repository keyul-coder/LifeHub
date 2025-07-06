//
//  Budget.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-07-05.
//

import Foundation

enum BudgetPeriod: Equatable {
    case weekly
    case monthly
    case custom(Int)
    
    var rawValue: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom(let days): return "Every \(days) days"
        }
    }
}

struct Budget: Identifiable {
    let id = UUID()
    var category: String
    var amount: Double
    var period: BudgetPeriod
    var timePeriod: String
    var alertEnabled: Bool
    var alertThreshold: Double // Value between 0.1 and 1.0
    var spentAmount: Double
    
    init(category: String, amount: Double, period: BudgetPeriod, alertEnabled: Bool, alertThreshold: Double, spentAmount: Double) {
        self.category = category
        self.amount = amount
        self.period = period
        self.alertEnabled = alertEnabled
        self.alertThreshold = alertThreshold
        self.spentAmount = spentAmount
        self.timePeriod=period.rawValue
    }

}
