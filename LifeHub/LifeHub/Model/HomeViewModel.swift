//
//  HomeViewModel.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

enum HomeSections: CaseIterable {
    
    case mainHeader
    case news
    /// Header Title(s)
    case feature
    case progress
    
    var cellIdentifier: String {
        switch self {
        case .mainHeader:
            return "cellHeader"
        case .news:
            return "cellNews"
            /// Header Title(s)
        case .feature, .progress:
            return "cellHeaderTitle"
        }
    }
    
    var title: String {
        switch self {
        case .mainHeader:
            return "Welcome to LifeHub"
        case .news:
            return "Latest News"
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
//    case finances
    case wellness
    case quotes
    case diet
    case badges
    case Mood
    
    var cellIdentifier: String {
        switch self {
        case .tasks, .habits, .wellness, .quotes, .diet, .badges, .Mood:
            return "cellFeatures"
        }
    }
    
    var title: String {
        switch self {
        case .habits:
            return "Habits"
//        case .finances:
//            return "Finances"
        case .tasks:
            return "Tasks"
        case .wellness:
            return "Wellness"
        case .quotes:
            return "Quotes"
        case .diet:
            return "Diet"
        case .badges:
            return "Badges"
        case .Mood:
            return "Mood"
        }
    }
    
    var subTitle: String {
        switch self {
//        case .finances:
//            return "Manage your finances here"
        case .habits:
            return "Track your daily habits"
        case .wellness:
            return "Prioritize your wellness"
        case .tasks:
            return "Organize your tasks"
        case .quotes:
            return "Inspirational quotes"
        case .diet:
            return "Track your diet"
        case .badges:
            return "Unlock special badges"
        case .Mood:
            return "Track your mood"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .habits:
            return "house"
//        case .finances:
//            return "dollarsign.circle"
        case .tasks:
            return "list.bullet"
        case .wellness:
            return "sunrise.fill"
        case .quotes:
            return "quote.bubble"
        case .diet:
            return "pencil"
        case .badges:
            return "star.fill"
        case .Mood:
            return "moon"
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
    var intakeRecords: [WaterIntake] = []
    var newsArticles:NewsArticle?
    var todayTasks: [ToDoTask] = []
    var completedTasksCount: Int {
        return todayTasks.filter { $0.isCompleted }.count
    }
}
