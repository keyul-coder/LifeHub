//
//  BadgeViewController.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-06-19.
//

import UIKit

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
        setupUI()
        setupCollectionView()
        loadUserData()
        updateUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Round header view corners
        headerView.layer.cornerRadius = 12
        headerView.clipsToBounds = true
        
        // Round milestone view corners
        nextMilestoneView.layer.cornerRadius = 8
        nextMilestoneView.backgroundColor = UIColor.systemGray6
        
        // Setup progress view
        progressView.progressTintColor = UIColor.systemBlue
        progressView.trackTintColor = UIColor.systemGray4
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Setup flow layout
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: 128, height: 128)
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = 10
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    private func loadUserData() {
        // Load saved data from UserDefaults
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        
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
        updateStreakLabels()
        updateMilestoneProgress()
        collectionView.reloadData()
    }
    
    private func updateStreakLabels() {
        // Update current streak
        currentStreakLabel.text = "\(currentStreak)"
        
        // Update badges earned count
        let earnedCount = badges.filter { $0.isEarned }.count
        let totalCount = badges.count
        badgesEarnedLabel.text = "\(earnedCount)/\(totalCount)"
        totalBadgesLabel.text = "\(totalCount)"
    }
    
    private func updateMilestoneProgress() {
        guard let nextBadge = getNextUnlockedBadge() else {
            // All badges earned
            nextMilestoneLabel.text = "All badges earned! 🎉"
            progressView.progress = 1.0
            progressLabel.text = "Congratulations!"
            return
        }
        
        let progress = Float(currentStreak) / Float(nextBadge.requiredStreak)
        let clampedProgress = min(progress, 1.0)
        
        nextMilestoneLabel.text = "Next Milestone: \(nextBadge.name)"
        progressView.progress = clampedProgress
        progressLabel.text = "\(currentStreak)/\(nextBadge.requiredStreak) days completed"
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
        
        // Increment streak
        currentStreak += 1
        saveUserData()
        
        // Show completion feedback
        let alert = UIAlertController(title: "Great Job!", message: "You've completed today's task and extended your streak to \(currentStreak) days!", preferredStyle: .alert)
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
