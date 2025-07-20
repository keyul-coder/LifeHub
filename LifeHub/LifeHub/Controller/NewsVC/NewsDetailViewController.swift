//
//  NewsDetailViewController.swift
//  LifeHub
//
//  Created by Smit Patel on 19/07/25.
//

import UIKit
import SafariServices

class NewsDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var articleDescriptionLabel: UILabel!
    @IBOutlet weak var readFullArticleButton: UIButton!
    
    // MARK: - Properties
    var newsArticle: NewsArticle?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithArticle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure image view
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.backgroundColor = .systemGray6
        articleImageView.layer.cornerRadius = 0
        
        // Configure labels with better typography
        articleTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        articleTitleLabel.textColor = .label
        articleTitleLabel.numberOfLines = 0
        articleTitleLabel.lineBreakMode = .byWordWrapping
        
        publishedDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        publishedDateLabel.textColor = .secondaryLabel
        
        articleDescriptionLabel.font = .systemFont(ofSize: 17, weight: .regular)
        articleDescriptionLabel.textColor = .label
        articleDescriptionLabel.numberOfLines = 0
        articleDescriptionLabel.lineBreakMode = .byWordWrapping
        
        // Configure button with better styling
        readFullArticleButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        readFullArticleButton.layer.cornerRadius = 12
        readFullArticleButton.backgroundColor = .systemBlue
        readFullArticleButton.setTitleColor(.white, for: .normal)
        
        // Add shadow to button
        readFullArticleButton.layer.shadowColor = UIColor.systemBlue.cgColor
        readFullArticleButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        readFullArticleButton.layer.shadowRadius = 4
        readFullArticleButton.layer.shadowOpacity = 0.3
    }
    
    // MARK: - Configuration
    private func configureWithArticle() {
        guard let article = newsArticle else {
            showErrorState()
            return
        }
        
        // Set title
        articleTitleLabel.text = article.title
        
        // Set description
        articleDescriptionLabel.text = article.description ?? "No description available for this article."
        
        // Set published date
        if let publishedAt = article.publishedAt {
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: publishedAt) {
                publishedDateLabel.text = "Published: \(dateFormatter.string(from: date))"
            } else {
                publishedDateLabel.text = "Published: \(dateFormatter.string(from: Date()))"
            }
        } else {
            publishedDateLabel.text = "Published: \(dateFormatter.string(from: Date()))"
        }
        
        // Load image
        loadArticleImage(from: article.urlToImage)
        
        // Enable/disable read full article button based on URL availability
        readFullArticleButton.isEnabled = !article.url.isEmpty
        readFullArticleButton.alpha = article.url.isEmpty ? 0.6 : 1.0
    }
    
    private func loadArticleImage(from urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            setPlaceholderImage()
            return
        }
        
        // Show loading state with activity indicator
        articleImageView.backgroundColor = .systemGray6
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        articleImageView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: articleImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: articleImageView.centerYAnchor)
        ])
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                guard let self = self,
                      let data = data,
                      error == nil,
                      let image = UIImage(data: data) else {
                    self?.setPlaceholderImage()
                    return
                }
                
                // Animate image appearance
                UIView.transition(with: self.articleImageView,
                                duration: 0.3,
                                options: .transitionCrossDissolve) {
                    self.articleImageView.image = image
                    self.articleImageView.contentMode = .scaleAspectFill
                }
            }
        }.resume()
    }
    
    private func setPlaceholderImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let placeholderImage = UIImage(systemName: "newspaper", withConfiguration: config)
        articleImageView.image = placeholderImage
        articleImageView.tintColor = .systemGray3
        articleImageView.contentMode = .center
    }
    
    private func showErrorState() {
        articleTitleLabel.text = "Article Not Available"
        articleDescriptionLabel.text = "Sorry, this article could not be loaded."
        publishedDateLabel.text = ""
        setPlaceholderImage()
        readFullArticleButton.isEnabled = false
        readFullArticleButton.alpha = 0.6
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let article = newsArticle else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        var itemsToShare: [Any] = [article.title]
        
        if !article.url.isEmpty {
            if let url = URL(string: article.url) {
                itemsToShare.append(url)
            }
        }
        
        if let description = article.description, !description.isEmpty {
            itemsToShare.append(description)
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func readFullArticleButtonTapped(_ sender: UIButton) {
        guard let article = newsArticle,
              !article.url.isEmpty,
              let url = URL(string: article.url) else {
            showAlert(title: "Error", message: "Unable to open article. URL not available.")
            return
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Show loading state on button
        readFullArticleButton.isEnabled = false
        readFullArticleButton.setTitle("Loading...", for: .normal)
        
        // Check network connectivity and open URL
        checkNetworkAndOpenURL(url)
        
        // Reset button state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.readFullArticleButton.isEnabled = true
            self.readFullArticleButton.setTitle("Read Full Article", for: .normal)
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func checkNetworkAndOpenURL(_ url: URL) {
        // Simple network check by trying to reach the URL
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5.0
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    // URL is reachable, open in Safari
                    let safariViewController = SFSafariViewController(url: url)
                    safariViewController.preferredBarTintColor = .systemBackground
                    safariViewController.preferredControlTintColor = .systemBlue
                    self?.present(safariViewController, animated: true)
                } else {
                    // URL not reachable or error occurred
                    self?.showAlert(
                        title: "Connection Error",
                        message: "Unable to load the article. Please check your internet connection and try again."
                    )
                }
            }
        }.resume()
    }
}

// MARK: - Static Factory Method
extension NewsDetailViewController {
    static func instantiate(with article: NewsArticle) -> NewsDetailViewController {
        let storyboard = UIStoryboard(name: "NewsDetail", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! NewsDetailViewController
        viewController.newsArticle = article
        return viewController
    }
}