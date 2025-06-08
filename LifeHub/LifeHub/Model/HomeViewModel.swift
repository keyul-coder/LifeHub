//
//  HomeViewModel.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

enum HomeSections: CaseIterable {
    
    case mainHeader
    /// Header Title(s)
    case feature
    case progress
    
    var cellIdentifier: String {
        switch self {
        case .mainHeader:
            return "cellHeader"
            /// Header Title(s)
        case .feature, .progress:
            return "cellHeaderTitle"
        }
    }
    
    var title: String {
        switch self {
        case .mainHeader:
            return "Welcome to LifeHub"
        case .feature:
            return "Features"
        case .progress:
            return "Progress"
        default:
            return ""
        }
    }
}

enum Features: CaseIterable {
    case tasks
    case habits
    case finances
    case wellness
    
    var cellIdentifier: String {
        switch self {
        case .tasks, .habits, .finances, .wellness:
            return "cellFeatures"
        }
    }
    
    var title: String {
        switch self {
        case .habits:
            return "Habits"
        case .finances:
            return "Finances"
        case .tasks:
            return "Tasks"
        case .wellness:
            return "Wellness"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .habits:
            return "house"
        case .finances:
            return "dollarsign.circle"
        case .tasks:
            return "list.bullet"
        case .wellness:
            return "sunrise.fill"
        }
    }
}

enum ProgressSection: CaseIterable {
    /// Progress Section
    case waterIntakeCell
    case taskProgressCell
    
    var cellIdentifier: String {
        switch self {
            /// Progress Section
        case .waterIntakeCell:
            return "cellWaterIntake"
        case .taskProgressCell:
            return "cellTaskProgress"
        }
    }
}

/// HomeViewModel
class HomeViewModel {
    
    /// Varaiable Declration(s)
    var arrSections: [HomeSections] = HomeSections.allCases
    var arrFeatures: [Features] = Features.allCases
    var arrProgressSections: [ProgressSection] = ProgressSection.allCases
}
