//
//  FavoritesViewController.swift
//  LifeHub
//
//  Created by keyul patel on 6/20/25.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    private let quoteManager = QuoteManager.shared
    private var favorites: [Quote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    private func setupTableView() {
        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        favoritesTableView.tableFooterView = UIView()
        favoritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteQuoteCell")
    }
    
    private func refreshData() {
        favorites = quoteManager.getFavorites()
        emptyStateLabel.isHidden = !favorites.isEmpty
        favoritesTableView.reloadData()
    }
    
    @IBAction func clearAllFavorites(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Clear All Favorites",
            message: "Are you sure you want to remove all favorite quotes?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            self.quoteManager.clearFavorites()
            self.refreshData()
        }))
        
        present(alert, animated: true)
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteQuoteCell", for: indexPath)
        let quote = favorites[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = quote.text
        content.secondaryText = "— \(quote.author)"
        content.textProperties.numberOfLines = 2
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // You could implement a detail view here if needed
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let quote = favorites[indexPath.row]
            quoteManager.removeFavorite(quote)
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            emptyStateLabel.isHidden = !favorites.isEmpty
        }
    }
}

