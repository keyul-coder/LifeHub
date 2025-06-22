//
//  DietCategory.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-06-19.
//

enum DietCategory: String, CaseIterable {
    case all = "all"
    case second = "Second"
    case muscles = "muscles"
    case balanced = "balanced"
    case keto = "keto"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .second: return "weight gain"
        case .muscles: return "Muscle Building"
        case .balanced: return "Balanced"
        case .keto: return "Keto"
        }
    }
}
