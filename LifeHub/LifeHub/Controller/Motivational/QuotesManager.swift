//
//  QuotesManager.swift
//  LifeHub
//
//  Created by keyul patel on 6/18/25.
//

import Foundation
import UserNotifications

class QuoteManager {
    static let shared = QuoteManager()
    
    private let favoritesKey = "favoriteQuotes"
    private let defaultCategoryKey = "defaultCategory"
    private let notificationsEnabledKey = "notificationsEnabled"
    private let notificationTimeKey = "notificationTime"
    private let fontSizeKey = "fontSize"
    
    private var quotes: [Quote] = []
    private var favorites: [Quote] = []
    
    init() {
        loadQuotes()
        loadFavorites()
    }
    
    // MARK: - Quotes Management
    
    private func loadQuotes() {
        // Load from bundled JSON
        if let path = Bundle.main.path(forResource: "quotes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                quotes = try JSONDecoder().decode([Quote].self, from: data)
            } catch {
                print("Error loading quotes: \(error)")
                quotes = sampleQuotes()
            }
        } else {
            quotes = sampleQuotes()
        }
    }
    
    private func sampleQuotes() -> [Quote] {
        return [
            // Motivation
            Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: "Motivation"),
            Quote(text: "Don’t watch the clock; do what it does. Keep going.", author: "Sam Levenson", category: "Motivation"),
            Quote(text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis", category: "Motivation"),
            Quote(text: "Push yourself, because no one else is going to do it for you.", author: "Unknown", category: "Motivation"),
            Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain", category: "Motivation"),
            
            // Success
            Quote(text: "Success is not final, failure is not fatal: It is the courage to continue that counts.", author: "Winston Churchill", category: "Success"),
            Quote(text: "Success is walking from failure to failure with no loss of enthusiasm.", author: "Winston Churchill", category: "Success"),
            Quote(text: "Success usually comes to those who are too busy to be looking for it.", author: "Henry David Thoreau", category: "Success"),
            Quote(text: "Success is not the key to happiness. Happiness is the key to success.", author: "Albert Schweitzer", category: "Success"),
            Quote(text: "The only place where success comes before work is in the dictionary.", author: "Vidal Sassoon", category: "Success"),
            
            // Happiness
            Quote(text: "Happiness is not something ready made. It comes from your own actions.", author: "Dalai Lama", category: "Happiness"),
            Quote(text: "The happiest people don’t have the best of everything, they make the best of everything.", author: "Unknown", category: "Happiness"),
            Quote(text: "Happiness is when what you think, what you say, and what you do are in harmony.", author: "Mahatma Gandhi", category: "Happiness"),
            Quote(text: "Be happy with what you have while working for what you want.", author: "Helen Keller", category: "Happiness"),
            Quote(text: "Happiness is not by chance, but by choice.", author: "Jim Rohn", category: "Happiness")
        ]
    }
    
    func getQuotes(for category: String) -> [Quote] {
        return quotes.filter { $0.category == category }
    }
    
    func getRandomQuote(for category: String) -> Quote? {
        let filtered = getQuotes(for: category)
        return filtered.randomElement()
    }
    
    // MARK: - Favorites Management
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            do {
                favorites = try JSONDecoder().decode([Quote].self, from: data)
            } catch {
                print("Error loading favorites: \(error)")
                favorites = []
            }
        }
    }
    
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("Error saving favorites: \(error)")
        }
    }
    
    func getFavorites() -> [Quote] {
        return favorites
    }
    
    func addFavorite(_ quote: Quote) {
        if !favorites.contains(quote) {
            favorites.append(quote)
            saveFavorites()
        }
    }
    
    func removeFavorite(_ quote: Quote) {
        favorites.removeAll { $0 == quote }
        saveFavorites()
    }
    
    func clearFavorites() {
        favorites.removeAll()
        saveFavorites()
    }
    
    func isFavorite(_ quote: Quote) -> Bool {
        return favorites.contains(quote)
    }
    
    // MARK: - Settings Management
    
    func getDefaultCategory() -> String {
        return UserDefaults.standard.string(forKey: defaultCategoryKey) ?? "Motivation"
    }
    
    func setDefaultCategory(_ category: String) {
        UserDefaults.standard.set(category, forKey: defaultCategoryKey)
    }
    
    func areNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }
    
    func setNotificationsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: notificationsEnabledKey)
        if enabled {
            scheduleDailyNotification()
        } else {
            cancelNotifications()
        }
    }
    
    func getNotificationTime() -> Date {
        return UserDefaults.standard.object(forKey: notificationTimeKey) as? Date ?? Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    }
    
    func setNotificationTime(_ time: Date) {
        UserDefaults.standard.set(time, forKey: notificationTimeKey)
        if areNotificationsEnabled() {
            scheduleDailyNotification()
        }
    }
    
    func getFontSize() -> CGFloat {
        return CGFloat(UserDefaults.standard.float(forKey: fontSizeKey))
    }
    
    func setFontSize(_ size: CGFloat) {
        UserDefaults.standard.set(Float(size), forKey: fontSizeKey)
    }
    
    // MARK: - Notification Management
    
    private func scheduleDailyNotification() {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Quote"
        content.body = "Check out today's inspirational quote!"
        content.sound = .default
        
        let time = getNotificationTime()
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyQuote", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyQuote"])
    }
    
    // MARK: - Data Export
    
    func exportFavorites() -> URL? {
        do {
            let data = try JSONEncoder().encode(favorites)
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("favorites.json")
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error exporting favorites: \(error)")
            return nil
        }
    }
}
