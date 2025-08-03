//
//  WellnessDiaryModel.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

import Foundation

/// WellnessDiaryModel
class WellnessDiaryModel: Codable {
    
    /// Variable(s)
    var id: String
    var text: String
    var date: Date
    
    init(text: String, date: Date) {
        self.id = UUID().uuidString
        self.text = text
        self.date = date
    }
    
    func formattedDateString() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, dd, yyyy" // or any custom format you prefer

        if calendar.isDateInToday(self.date) {
            return "Today"
        } else {
            return formatter.string(from: self.date)
        }
    }
    
    /// Save diary entries locally and sync to Firebase
    class func saveDiaryEntries(_ entries: [WellnessDiaryModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "wellnessDiaryEntries")
        }
        
        // Sync to Firebase
        FirebaseManager.shared.saveWellnessDiary(entries) { _ in }
    }
    
    class func loadDiaryEntries() -> [WellnessDiaryModel] {
        if let data = UserDefaults.standard.data(forKey: "wellnessDiaryEntries") {
            let decoder = JSONDecoder()
            if let entries = try? decoder.decode([WellnessDiaryModel].self, from: data) {
                return entries
            }
        }
        return []
    }
    
    // MARK: - Firebase Integration
    
    class func syncFromFirebase(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.loadWellnessDiary { result in
            switch result {
            case .success(let entries):
                // Save to local storage
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(entries) {
                    UserDefaults.standard.set(encoded, forKey: "wellnessDiaryEntries")
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
}
