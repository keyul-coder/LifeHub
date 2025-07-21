//
//  NewsCardCell.swift
//  LifeHub
//
//  Created by Smit Patel on 20/07/25.
//

import UIKit

class NewsCardCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var newsIconImageView: UIImageView!
    
    // MARK: - Properties
    private var currentArticle: NewsArticle?
    weak var parentVC: HomeVC!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTapGesture()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Container styling
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.label.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = false
        
        // News image styling
        newsImageView.layer.cornerRadius = 12
        newsImageView.clipsToBounds = true
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.backgroundColor = .systemGray6
        
        // News icon styling
        newsIconImageView.tintColor = .systemBlue
        newsIconImageView.image = UIImage(systemName: "newspaper.fill")
        
        // Label styling
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        
        sourceLabel.font = .systemFont(ofSize: 12, weight: .medium)
        sourceLabel.textColor = .systemBlue
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newsCardTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    @objc private func newsCardTapped() {
        guard let parentVC = parentVC else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Navigate to news list
        parentVC.navigateToNewsDetail()
    }
    
    // MARK: - Configuration
    func configure(with article: NewsArticle) {
        currentArticle = article
        
        titleLabel.text = article.title
        subtitleLabel.text = article.description ?? "Tap to read more news articles"
        
        // Configure source
        if let source = article.source?.name {
            sourceLabel.text = source
        } else {
            sourceLabel.text = "News"
        }
        
        // Load image
        loadImage(from: article.urlToImage)
    }
    
    // MARK: - Image Loading
    private func loadImage(from urlString: String?) {
        newsImageView.image = nil
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            setPlaceholderImage()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self,
                      let data = data,
                      error == nil,
                      let image = UIImage(data: data) else {
                    self?.setPlaceholderImage()
                    return
                }
                
                UIView.transition(with: self.newsImageView,
                                duration: 0.3,
                                options: .transitionCrossDissolve) {
                    self.newsImageView.image = image
                }
            }
        }.resume()
    }
    
    private func setPlaceholderImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .light)
        let placeholderImage = UIImage(systemName: "newspaper", withConfiguration: config)
        newsImageView.image = placeholderImage
        newsImageView.tintColor = .systemGray3
        newsImageView.contentMode = .center
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        sourceLabel.text = nil
        currentArticle = nil
    }
}
