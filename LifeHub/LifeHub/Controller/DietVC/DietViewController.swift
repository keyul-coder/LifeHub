//
//  DietViewController.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-06-19.
//

import UIKit

class DietViewController: UIViewController {
    
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var dietPlans: [DietPlan] = []
    private var filteredDietPlans: [DietPlan] = []
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadDietPlans()
    }
    
    private func setupView() {
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup search bar
        searchBar.delegate = self
        
        // Remove the segue connection from segmented control
        // We'll handle category changes programmatically
        categorySegmentedControl.addTarget(self, action: #selector(categoryChanged(_:)), for: .valueChanged)
        
        // Set initial category to "all"
        categorySegmentedControl.selectedSegmentIndex = 0
    }
    
    private func loadDietPlans() {
        let selectedCategory = getCategoryFromSegmentedControl()
        dietPlans = DietPlanData.shared.getDietPlans(for: selectedCategory)
        filteredDietPlans = dietPlans
        tableView.reloadData()
    }
    
    @objc private func categoryChanged(_ sender: UISegmentedControl) {
        loadDietPlans()
        
        // Clear search if active
        if isSearching {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            isSearching = false
        }
    }
    
    private func getCategoryFromSegmentedControl() -> String {
        let categories = ["all", "weight", "muscles", "balanced", "keto"]
        let selectedIndex = categorySegmentedControl.selectedSegmentIndex
        return categories[selectedIndex]
    }
    
    // Prepare for segue to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDietDetail",
           let destinationVC = segue.destination as? DietDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            let selectedDietPlan = isSearching ? filteredDietPlans[indexPath.row] : dietPlans[indexPath.row]
            destinationVC.dietPlan = selectedDietPlan
        }
    }
}

// MARK: - UITableViewDataSource
extension DietViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredDietPlans.count : dietPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DietPlanCell", for: indexPath) as? DietPlanTableViewCell else {
            return UITableViewCell()
        }
        
        let dietPlan = isSearching ? filteredDietPlans[indexPath.row] : dietPlans[indexPath.row]
        cell.configure(with: dietPlan)
        return cell
    }
    

}

// MARK: - UITableViewDelegate
extension DietViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDietDetail", sender: self)
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UISearchBarDelegate
extension DietViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredDietPlans = dietPlans
        } else {
            isSearching = true
            filteredDietPlans = dietPlans.filter { dietPlan in
                dietPlan.name.lowercased().contains(searchText.lowercased()) ||
                dietPlan.description.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredDietPlans = dietPlans
        tableView.reloadData()
    }
}
