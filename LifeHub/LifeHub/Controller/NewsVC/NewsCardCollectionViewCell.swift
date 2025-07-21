//
//  NewsCardCollectionViewCell.swift
//  LifeHub
//
//  Created by Smit Patel on 19/07/25.
//

import UIKit

class NewsCardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private var currentArticle: NewsArticle?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        contentView.addSubview(containerView)
        containerView.addSubview(newsImageView)
        containerView.addSubview(textContainerView)
        
        textContainerView.addSubview(titleLabel)
        textContainerView.addSubview(descriptionLabel)
        textContainerView.addSubview(sourceLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // News image view
            newsImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newsImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newsImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Text container view
            textContainerView.topAnchor.constraint(equalTo: newsImageView.bottomAnchor, constant: 8),
            textContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            textContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            
            // Source label
            sourceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            sourceLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            sourceLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            sourceLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with article: NewsArticle) {
        currentArticle = article
        
        titleLabel.text = article.title
        descriptionLabel.text = article.description ?? "No description available"
        
        // Configure source label
        var sourceText = ""
        if let source = article.source?.name {
            sourceText = source
        }
        
        if let publishedAt = article.publishedAt {
            let timeAgo = formatTimeAgo(from: publishedAt)
            if !sourceText.isEmpty {
                sourceText += " • \(timeAgo)"
            } else {
                sourceText = timeAgo
            }
        }
        
        sourceLabel.text = sourceText.isEmpty ? "Unknown source" : sourceText
        
        // Load image
        loadImage(from: article.urlToImage)
    }
    
    // MARK: - Image Loading
    private func loadImage(from urlString: String?) {
        // Reset image
        newsImageView.image = nil
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            setPlaceholderImage()
            return
        }
        
        // Show loading state
        newsImageView.backgroundColor = .systemGray6
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self,
                      let data = data,
                      error == nil,
                      let image = UIImage(data: data) else {
                    self?.setPlaceholderImage()
                    return
                }
                
                // Animate image appearance
                UIView.transition(with: self.newsImageView,
                                duration: 0.3,
                                options: .transitionCrossDissolve) {
                    self.newsImageView.image = image
                }
            }
        }.resume()
    }
    
    private func setPlaceholderImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        let placeholderImage = UIImage(systemName: "newspaper", withConfiguration: config)
        newsImageView.image = placeholderImage
        newsImageView.tintColor = .systemGray3
        newsImageView.contentMode = .center
    }
    
    // MARK: - Helper Methods
    private func formatTimeAgo(from dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: dateString) else {
            return "Recently"
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 3600 { // Less than 1 hour
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 { // Less than 1 day
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else { // More than 1 day
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        sourceLabel.text = nil
        currentArticle = nil
    }
}