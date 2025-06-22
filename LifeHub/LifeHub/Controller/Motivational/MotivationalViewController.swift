//
//  MotivationalViewController.swift
//  LifeHub
//
//  Created by keyul patel on 6/18/25.
//

import UIKit

class MotivationalViewController: UIViewController {
    
    // Outlets from storyboard
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var quoteTextLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var quoteCardView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private let quoteManager = QuoteManager.shared
    private var currentCategory: String = "Motivation"
    private var currentQuotes: [Quote] = []
    private var currentIndex: Int = 0
    private var currentQuote: Quote? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialData()
    }
    
    private func setupUI() {
        quoteCardView.layer.cornerRadius = 12
        quoteCardView.layer.shadowColor = UIColor.black.cgColor
        quoteCardView.layer.shadowOpacity = 0.1
        quoteCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        quoteCardView.layer.shadowRadius = 4
        
        // Set initial category from settings
        currentCategory = quoteManager.getDefaultCategory()
        if let index = ["Motivation", "Success", "Happiness"].firstIndex(of: currentCategory) {
            categorySegmentedControl.selectedSegmentIndex = index
        }
    }
    
    private func loadInitialData() {
        activityIndicator.startAnimating()
        currentQuotes = quoteManager.getQuotes(for: currentCategory)
        currentIndex = 0
        
        if !currentQuotes.isEmpty {
            currentQuote = currentQuotes[currentIndex]
        } else {
            showNoQuotesAlert()
        }
        activityIndicator.stopAnimating()
    }
    
    private func updateUI() {
        guard let quote = currentQuote else { return }
        
        quoteTextLabel.text = quote.text
        authorLabel.text = "— \(quote.author)"
        
        // Update favorite button state
        let isFavorite = quoteManager.isFavorite(quote)
        favoriteButton.isSelected = isFavorite
        favoriteButton.tintColor = isFavorite ? .systemRed : .systemGray
    }
    
    private func showNoQuotesAlert() {
        let alert = UIAlertController(
            title: "No Quotes Available",
            message: "There are no quotes in the selected category.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        let categories = ["Motivation", "Success", "Happiness"]
        currentCategory = categories[sender.selectedSegmentIndex]
        loadInitialData()
    }
    
    @IBAction func favoritePressed(_ sender: UIButton) {
        guard let quote = currentQuote else { return }
        
        sender.isSelected.toggle()
        
        if sender.isSelected {
            quoteManager.addFavorite(quote)
            sender.tintColor = .systemRed
        } else {
            quoteManager.removeFavorite(quote)
            sender.tintColor = .systemGray
        }
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        guard let quote = currentQuote else { return }
        
        
        let text = "\(quote.text)\n— \(quote.author)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @IBAction func previousQuotePressed(_ sender: UIButton) {
        guard !currentQuotes.isEmpty else { return }
        
        currentIndex = (currentIndex - 1 + currentQuotes.count) % currentQuotes.count
        currentQuote = currentQuotes[currentIndex]
    }
    
    @IBAction func nextQuotePressed(_ sender: UIButton) {
        guard !currentQuotes.isEmpty else { return }
        
        currentIndex = (currentIndex + 1) % currentQuotes.count
        currentQuote = currentQuotes[currentIndex]
    }
    
    @IBAction func randomButtonTapped(_ sender: UIButton) {
        guard !currentQuotes.isEmpty else { return }
        
        var newIndex = currentIndex
        while newIndex == currentIndex && currentQuotes.count > 1 {
            newIndex = Int.random(in: 0..<currentQuotes.count)
        }
        currentIndex = newIndex
        currentQuote = currentQuotes[currentIndex]
    }
}


//extension MotivationalViewController {
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
