//
//  BadgeViewController.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-06-19.
//

import UIKit
import CoreData

// MARK: - Badge Model
struct Badge {
    let name: String
    let requirement: String
    let iconName: String
    let requiredStreak: Int
    var isEarned: Bool
}

class BadgeViewController: ParentVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var badgesEarnedLabel: UILabel!
    @IBOutlet weak var totalBadgesLabel: UILabel!
    @IBOutlet weak var nextMilestoneView: UIView!
    @IBOutlet weak var nextMilestoneLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    // MARK: - Properties
    private var currentStreak: Int = 0 {
        didSet {
            updateUI()
            checkForNewBadges()
        }
    }
    
    private var badges: [Badge] = [
        Badge(name: "First Step", requirement: "1 day streak", iconName: "star.fill", requiredStreak: 1, isEarned: false),
        Badge(name: "Getting Started", requirement: "3 day streak", iconName: "flame.fill", requiredStreak: 3, isEarned: false),
        Badge(name: "One Week", requirement: "7 day streak", iconName: "calendar", requiredStreak: 7, isEarned: false),
        Badge(name: "Two Weeks", requirement: "14 day streak", iconName: "trophy.fill", requiredStreak: 14, isEarned: false),
        Badge(name: "One Month", requirement: "30 day streak", iconName: "crown.fill", requiredStreak: 30, isEarned: false),
        Badge(name: "Streak Master", requirement: "50 day streak", iconName: "diamond.fill", requiredStreak: 50, isEarned: false),
        Badge(name: "Dedication", requirement: "75 day streak", iconName: "medal.fill", requiredStreak: 75, isEarned: false),
        Badge(name: "Century", requirement: "100 day streak", iconName: "100.square.fill", requiredStreak: 100, isEarned: false),
        Badge(name: "Legendary", requirement: "200 day streak", iconName: "sparkles", requiredStreak: 200, isEarned: false),
        Badge(name: "Ultimate", requirement: "365 day streak", iconName: "infinity", requiredStreak: 365, isEarned: false)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🏆 BadgeViewController viewDidLoad called")
        setupUI()
        setupCollectionView()
        setupNotifications()
        loadUserData()
        updateUI()
        print("🏆 BadgeViewController setup completed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when view appears
        refreshStreakData()
        checkDailyAchievements()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        print("🏆 Setting up UI...")
        
        // Round header view corners
        headerView?.layer.cornerRadius = 12
        headerView?.clipsToBounds = true
        
        // Round milestone view corners
        nextMilestoneView?.layer.cornerRadius = 8
        nextMilestoneView?.backgroundColor = UIColor.systemGray6
        
        // Setup progress view
        progressView?.progressTintColor = UIColor.systemBlue
        progressView?.trackTintColor = UIColor.systemGray4
        
        print("🏆 UI setup completed")
    }
    
    private func setupCollectionView() {
        print("🏆 Setting up collection view...")
        
        guard let collectionView = collectionView else {
            print("❌ Collection view is nil!")
            return
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Setup flow layout
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: 160, height: 160)
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.minimumLineSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            print("🏆 Collection view layout configured")
        } else {
            print("❌ Failed to get flow layout")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(streakUpdated(_:)),
            name: .streakUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(taskCompleted(_:)),
            name: .taskCompleted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(badgeEarned(_:)),
            name: .badgeEarned,
            object: nil
        )
    }
    
    @objc private func streakUpdated(_ notification: Notification) {
        if let newStreak = notification.userInfo?["newStreak"] as? Int {
            currentStreak = newStreak
            DispatchQueue.main.async {
                self.updateUI()
                self.checkDailyAchievements()
            }
        }
    }
    
    @objc private func taskCompleted(_ notification: Notification) {
        DispatchQueue.main.async {
            self.refreshStreakData()
            self.checkDailyAchievements()
        }
    }
    
    @objc private func badgeEarned(_ notification: Notification) {
        if let badgeName = notification.userInfo?["badgeName"] as? String {
            DispatchQueue.main.async {
                self.updateBadgesFromManager()
                self.updateUI()
                
                // Show badge earned animation
                if let badgeIndex = self.badges.firstIndex(where: { $0.name == badgeName }) {
                    let indexPath = IndexPath(item: badgeIndex, section: 0)
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? BadgeCollectionViewCell {
                        cell.animateEarned()
                    }
                }
                
                // Show alert
                let badge = self.badges.first { $0.name == badgeName }
                if let badge = badge {
                    self.showBadgeEarnedAlert(badges: [badge])
                }
            }
        }
    }
    
    private func loadUserData() {
        // Load saved data from UserDefaults and sync with TaskManager
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        
        // Update streak based on actual task completion
        updateStreakFromTaskCompletion()
        
        // Load earned badges
        if let earnedBadgesData = UserDefaults.standard.data(forKey: "earnedBadges"),
           let earnedBadgeNames = try? JSONDecoder().decode([String].self, from: earnedBadgesData) {
            for i in 0..<badges.count {
                badges[i].isEarned = earnedBadgeNames.contains(badges[i].name)
            }
        }
    }
    
    private func saveUserData() {
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        
        let earnedBadgeNames = badges.filter { $0.isEarned }.map { $0.name }
        if let data = try? JSONEncoder().encode(earnedBadgeNames) {
            UserDefaults.standard.set(data, forKey: "earnedBadges")
        }
    }
    
    // MARK: - UI Update Methods
    private func updateUI() {
        print("🏆 Updating UI...")
        updateStreakLabels()
        updateMilestoneProgress()
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            print("🏆 Collection view reloaded")
        }
    }
    
    private func updateStreakLabels() {
        // Update current streak
        currentStreakLabel?.text = "\(currentStreak)"
        
        // Update badges earned count
        let earnedCount = badges.filter { $0.isEarned }.count
        let totalCount = badges.count
        badgesEarnedLabel?.text = "\(earnedCount)/\(totalCount)"
        totalBadgesLabel?.text = "\(totalCount)"
        
        print("🏆 Updated labels - Streak: \(currentStreak), Badges: \(earnedCount)/\(totalCount)")
    }
    
    private func updateMilestoneProgress() {
        guard let nextBadge = getNextUnlockedBadge() else {
            // All badges earned
            nextMilestoneLabel?.text = "All badges earned! 🎉"
            progressView?.progress = 1.0
            progressLabel?.text = "Congratulations!"
            print("🏆 All badges earned!")
            return
        }
        
        let progress = Float(currentStreak) / Float(nextBadge.requiredStreak)
        let clampedProgress = min(progress, 1.0)
        
        nextMilestoneLabel?.text = "Next Milestone: \(nextBadge.name)"
        progressView?.progress = clampedProgress
        progressLabel?.text = "\(currentStreak)/\(nextBadge.requiredStreak) days completed"
        
        print("🏆 Updated milestone progress: \(nextBadge.name) - \(currentStreak)/\(nextBadge.requiredStreak)")
    }
    
    private func getNextUnlockedBadge() -> Badge? {
        return badges.first { !$0.isEarned && $0.requiredStreak > currentStreak }
    }
    
    private func checkForNewBadges() {
        var newBadges: [Badge] = []
        
        for i in 0..<badges.count {
            if !badges[i].isEarned && currentStreak >= badges[i].requiredStreak {
                badges[i].isEarned = true
                newBadges.append(badges[i])
            }
        }
        
        if !newBadges.isEmpty {
            saveUserData()
            showBadgeEarnedAlert(badges: newBadges)
        }
    }
    
    private func showBadgeEarnedAlert(badges: [Badge]) {
        let title = badges.count == 1 ? "Badge Earned!" : "Badges Earned!"
        let badgeNames = badges.map { $0.name }.joined(separator: ", ")
        let message = "Congratulations! You've earned: \(badgeNames)"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Streak Management
    
    private func updateStreakFromTaskCompletion() {
        // Get current streak from TaskManager
        let taskManagerStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        
        // Check if we need to update streak based on task completion
        let lastStreakUpdate = UserDefaults.standard.object(forKey: "lastStreakUpdate") as? Date
        let today = Date()
        
        if let lastUpdate = lastStreakUpdate {
            let calendar = Calendar.current
            
            // Check if it's a new day
            if !calendar.isDate(lastUpdate, inSameDayAs: today) {
                // Check if user completed tasks today
                let todayTasksCompleted = TaskManager.shared.getTodaysCompletedTasksCount()
                
                if todayTasksCompleted > 0 {
                    // User completed tasks today
                    if calendar.isDate(lastUpdate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!) {
                        // Consecutive day - maintain/increment streak
                        currentStreak = taskManagerStreak
                    } else {
                        // Gap in days - reset streak
                        currentStreak = 1
                        UserDefaults.standard.set(1, forKey: "currentStreak")
                    }
                    UserDefaults.standard.set(today, forKey: "lastStreakUpdate")
                } else {
                    // No tasks completed today - check if streak should be broken
                    let daysSinceLastUpdate = calendar.dateComponents([.day], from: lastUpdate, to: today).day ?? 0
                    if daysSinceLastUpdate > 1 {
                        // Streak broken
                        currentStreak = 0
                        UserDefaults.standard.set(0, forKey: "currentStreak")
                    }
                }
            } else {
                // Same day - use current streak
                currentStreak = taskManagerStreak
            }
        } else {
            // First time - check if user has completed tasks today
            let todayTasksCompleted = TaskManager.shared.getTodaysCompletedTasksCount()
            if todayTasksCompleted > 0 {
                currentStreak = 1
                UserDefaults.standard.set(1, forKey: "currentStreak")
                UserDefaults.standard.set(today, forKey: "lastStreakUpdate")
            }
        }
    }
    
    func refreshStreakData() {
        // Public method to refresh streak data when called from other view controllers
        updateStreakFromTaskCompletion()
        updateUI()
        saveUserData()
    }
    
    // MARK: - Achievement System
    
    private func checkDailyAchievements() {
        // Use BadgeManager to check all achievements
        BadgeManager.shared.checkAllBadges()
        
        // Update badges array with earned badges
        updateBadgesFromManager()
    }
    
    private func updateBadgesFromManager() {
        let earnedBadgeNames = BadgeManager.shared.getEarnedBadges()
        
        // Update existing badges
        for i in 0..<badges.count {
            badges[i].isEarned = earnedBadgeNames.contains(badges[i].name)
        }
        
        // Add any new special badges that aren't in the default list
        let defaultBadgeNames = badges.map { $0.name }
        let newBadgeNames = earnedBadgeNames.filter { !defaultBadgeNames.contains($0) }
        
        for badgeName in newBadgeNames {
            let newBadge = createSpecialBadge(name: badgeName)
            badges.append(newBadge)
        }
    }
    
    private func createSpecialBadge(name: String) -> Badge {
        let iconName: String
        let requirement: String
        
        switch name {
        case "Task Starter":
            iconName = "checkmark.circle.fill"
            requirement = "Complete 1 task in a day"
        case "Daily Champion":
            iconName = "star.circle.fill"
            requirement = "Complete 3+ tasks in a day"
        case "Productivity Master":
            iconName = "bolt.circle.fill"
            requirement = "Complete 5+ tasks in a day"
        case "Task Warrior":
            iconName = "shield.fill"
            requirement = "Complete 10+ tasks in a day"
        case "Hydration Start":
            iconName = "drop.circle.fill"
            requirement = "Drink 1L+ water in a day"
        case "Well Hydrated":
            iconName = "drop.fill"
            requirement = "Drink 2L+ water in a day"
        case "Hydration Hero":
            iconName = "drop.triangle.fill"
            requirement = "Drink 2.5L+ water in a day"
        case "Water Champion":
            iconName = "drop.keypad.rectangle.fill"
            requirement = "Drink 3L+ water in a day"
        case "Mindful Moment":
            iconName = "heart.fill"
            requirement = "Write a wellness diary entry"
        case "Wellness Week":
            iconName = "heart.circle.fill"
            requirement = "Write 7 wellness entries"
        case "Mindful Month":
            iconName = "heart.rectangle.fill"
            requirement = "Write 30 wellness entries"
        case "Wellness Guru":
            iconName = "heart.text.square.fill"
            requirement = "Write 100 wellness entries"
        case "Consistent Starter":
            iconName = "calendar.circle.fill"
            requirement = "Complete tasks 3 days this week"
        case "Weekly Warrior":
            iconName = "calendar.badge.plus"
            requirement = "Complete tasks 5 days this week"
        case "Perfect Week":
            iconName = "calendar.badge.checkmark"
            requirement = "Complete tasks every day this week"
        case "Perfect Day":
            iconName = "sun.max.fill"
            requirement = "Complete tasks, drink water, and write wellness entry"
        case "Comeback Kid":
            iconName = "arrow.up.circle.fill"
            requirement = "Rebuild your streak after a break"
        case "Early Bird":
            iconName = "sunrise.fill"
            requirement = "Complete a task before 9 AM"
        default:
            iconName = "star.fill"
            requirement = "Special achievement"
        }
        
        return Badge(name: name, requirement: requirement, iconName: iconName, requiredStreak: 0, isEarned: true)
    }
    
    // MARK: - IBActions
    @IBAction func completeStreakTapped(_ sender: UIButton) {
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
            }
        }
        
        // Check if user has actually completed tasks today
        let todayTasksCompleted = TaskManager.shared.getTodaysCompletedTasksCount()
        
        if todayTasksCompleted == 0 {
            let alert = UIAlertController(
                title: "No Tasks Completed",
                message: "Complete at least one task today to maintain your streak!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Update streak based on actual task completion
        TaskManager.shared.updateStreakIfNeeded()
        refreshStreakData()
        checkDailyAchievements()
        
        // Get statistics for feedback
        let stats = BadgeManager.shared.getBadgeStatistics()
        let earnedBadges = stats["earnedBadges"] as? Int ?? 0
        
        // Show completion feedback with achievements
        let message = """
        🎉 Streak: \(currentStreak) days
        ✅ Tasks completed today: \(todayTasksCompleted)
        🏆 Total badges earned: \(earnedBadges)
        
        Keep up the great work!
        """
        
        let alert = UIAlertController(title: "Great Job!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource
extension BadgeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as? BadgeCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let badge = badges[indexPath.item]
        cell.configure(with: badge)
        
        return cell
    }
}

// MARK: - UICollectionView Delegate
extension BadgeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = badges[indexPath.item]
        
        let status = badge.isEarned ? "Earned ✅" : "Not earned yet"
        let message = "\(badge.requirement)\nStatus: \(status)"
        
        let alert = UIAlertController(title: badge.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
