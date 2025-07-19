//
//  MainHeaderCollectionViewCell.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

import UIKit

class MainHeaderCollectionViewCell: UICollectionViewCell {
    
    /// @IBOutlet(s)
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lblUSerName: UILabel!
    @IBOutlet weak var lblTaksDoneValue: UILabel!
    @IBOutlet weak var lblDaysStreakValue: UILabel!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var lblWaterIntakePercentageValue: UILabel!
    @IBOutlet weak var newsSubtitle: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    /// Variable Declaration(s)
    private var currentArticle: NewsArticle?
    
    /// Carried Varaiable(s)
    weak var parentVC: HomeVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNewsCardTapGesture()
    }
    
    private func setupNewsCardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newsCardTapped))
        
        // Create a container view for the news section if it doesn't exist
        // Assuming the news section includes the image, title, and subtitle
        if let newsContainer = createNewsContainerView() {
            newsContainer.addGestureRecognizer(tapGesture)
            newsContainer.isUserInteractionEnabled = true
        }
    }
    
    private func createNewsContainerView() -> UIView? {
        // Find the common superview of news elements
        guard let imageSuperview = newImage.superview,
              let titleSuperview = newsTitle.superview,
              let subtitleSuperview = newsSubtitle.superview,
              imageSuperview == titleSuperview && titleSuperview == subtitleSuperview else {
            // If they don't share the same superview, add gesture to the cell itself
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newsCardTapped))
            self.addGestureRecognizer(tapGesture)
            self.isUserInteractionEnabled = true
            return self
        }
        
        return imageSuperview
    }
    
    @objc private func newsCardTapped() {
        guard let parentVC = parentVC else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Navigate to news list using parent VC method
        parentVC.navigateToNewsDetail()
    }
    
    func setupdate(data: NewsArticle) {
        self.currentArticle = data
        self.newsTitle.text = data.title
        self.newsSubtitle.text = data.description
        if let urlString = data.urlToImage, let url = URL(string: urlString) {
            self.loadImage(from: url)
        }
    }
    
    func updateWaterIntakePercentage(currentIntake: Int, dailyGoal: Int = WaterIntakeConstants.defaultDailyGoal) {
        let calculatedPercentage = Int(Double(currentIntake) / Double(dailyGoal) * 100)
        let percentage = Swift.min(calculatedPercentage, 100)
        self.lblWaterIntakePercentageValue.text = "\(percentage)%"
    }
    
    func updateWaterIntakeWithRecords(_ records: [WaterIntake]) {
        let percentage = records.intakePercentage()
        self.lblWaterIntakePercentageValue.text = "\(percentage)%"
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.newImage.image = image
                }
            }
        }.resume()
    }    
}
