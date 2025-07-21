//
//  NewsListViewController.swift
//  LifeHub
//
//  Created by Smit Patel on 19/07/25.
//

import UIKit

class NewsListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let newsService = NewsService()
    private var allNewsData: [NewsCategory: [NewsArticle]] = [:]
    private var currentArticles: [NewsArticle] = []
    private var selectedCategory: NewsCategory = .health
    
    private let categories: [NewsCategory] = [.health, .technology, .sports, .business, .general]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        loadNews()
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
        
        // Configure segmented control
        categorySegmentedControl.removeAllSegments()
        categorySegmentedControl.insertSegment(withTitle: "All", at: 0, animated: false)
        for (index, category) in categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category.displayName, at: index + 1, animated: false)
        }
        categorySegmentedControl.selectedSegmentIndex = 1 // Health by default
        
        // Style segmented control
        categorySegmentedControl.backgroundColor = .systemGray6
        categorySegmentedControl.selectedSegmentTintColor = .systemBlue
        categorySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        categorySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    private func setupCollectionView() {
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        newsCollectionView.backgroundColor = .systemBackground
        
        // Configure flow layout
        if let flowLayout = newsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.minimumLineSpacing = 16
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        // Register cell
        newsCollectionView.register(NewsCardCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCardCell")
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        newsCollectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshNews() {
        loadNews()
        newsCollectionView.refreshControl?.endRefreshing()
    }
    
    // MARK: - Data Loading
    private func loadNews() {
        showLoading(true)
        
        newsService.fetchAllCategoriesNews { [weak self] newsData in
            DispatchQueue.main.async {
                self?.allNewsData = newsData
                self?.updateCurrentArticles()
                self?.showLoading(false)
            }
        }
    }
    
    private func updateCurrentArticles() {
        if categorySegmentedControl.selectedSegmentIndex == 0 {
            // Show all articles
            currentArticles = allNewsData.values.flatMap { $0 }.shuffled()
        } else {
            // Show specific category
            let categoryIndex = categorySegmentedControl.selectedSegmentIndex - 1
            if categoryIndex < categories.count {
                selectedCategory = categories[categoryIndex]
                currentArticles = allNewsData[selectedCategory] ?? []
            }
        }
        
        newsCollectionView.reloadData()
        
        // Show empty state if no articles
        if currentArticles.isEmpty && !loadingIndicator.isAnimating {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No news articles available"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textAlignment = .center
        emptyLabel.tag = 999 // Tag to identify and remove later
        
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func hideEmptyState() {
        view.subviews.first { $0.tag == 999 }?.removeFromSuperview()
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            newsCollectionView.alpha = 0.5
        } else {
            loadingIndicator.stopAnimating()
            newsCollectionView.alpha = 1.0
        }
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        // Add haptic feedback
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        updateCurrentArticles()
    }
    
    // MARK: - Navigation
    private func navigateToNewsDetail(with article: NewsArticle) {
        let newsDetailVC = NewsDetailViewController.instantiate(with: article)
        navigationController?.pushViewController(newsDetailVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension NewsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentArticles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCardCell", for: indexPath) as! NewsCardCollectionViewCell
        let article = currentArticles[indexPath.item]
        cell.configure(with: article)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let article = currentArticles[indexPath.item]
        navigateToNewsDetail(with: article)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32 // 16 padding on each side
        return CGSize(width: width, height: 200)
    }
}

// MARK: - Static Factory Method
extension NewsListViewController {
    static func instantiate() -> NewsListViewController {
        let storyboard = UIStoryboard(name: "NewsList", bundle: nil)
        return storyboard.instantiateInitialViewController() as! NewsListViewController
    }
}