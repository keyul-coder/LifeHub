//
//  BudgetListViewController.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-07-05.
//

import UIKit
import UserNotifications

class BudgetListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var budgets: [Budget] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBudgets()
        let nib = UINib(nibName: "BudgetTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BudgetTableViewCell")


    }
    
    private func setupUI() {
        title = "Budget Manager"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BudgetCell")
        
        addButton.layer.cornerRadius = 30
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowRadius = 4
        addButton.layer.shadowOpacity = 0.3
    }
    
    private func loadBudgets() {
        // In a real app, you would load from CoreData or another persistence layer
        // For demo purposes, we'll use some sample data
        budgets = [
            Budget(category: "Groceries", amount: 500.0, period: .weekly, alertEnabled: true, alertThreshold: 0.8, spentAmount: 250.0),
            Budget(category: "Entertainment", amount: 200.0, period: .monthly, alertEnabled: false, alertThreshold: 0.9, spentAmount: 50.0)
        ]
        for budget in budgets {
               let spentRatio = budget.spentAmount / budget.amount
               if budget.alertEnabled && spentRatio >= budget.alertThreshold {
                   scheduleNotification(for: budget)
               }
           }
        tableView.reloadData()
    }
    func scheduleNotification(for budget: Budget) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Budget Limit Reached"
        content.body = "You have spent over \(Int(budget.alertThreshold * 100))% of your \(budget.category) budget."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "budgetAlert_\(budget.category)",
            content: content,
            trigger: nil // Trigger immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(budget.category)")
            }
        }
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgets.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath)
//        let budget = budgets[indexPath.row]
//
//        var content = cell.defaultContentConfiguration()
//        content.text = budget.category
//        content.secondaryText = "\(budget.amount.currencyString) - \(budget.period.rawValue)"
//
//        // Progress bar for the cell
//        let progressView = UIProgressView(progressViewStyle: .default)
//        progressView.progress = Float(budget.spentAmount / budget.amount)
//        progressView.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 2)
//        progressView.trackTintColor = .systemGray5
//        progressView.progressTintColor = budget.spentAmount > budget.amount ? .systemRed : .systemBlue
//
//        cell.contentConfiguration = content
//        cell.contentView.addSubview(progressView)
//
//        return cell
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetTableViewCell", for: indexPath) as? BudgetTableViewCell else {
               return UITableViewCell()
           }
           let budget = budgets[indexPath.row]
           cell.configure(with: budget)
           return cell
       }

       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           let budget = budgets[indexPath.row]
           performSegue(withIdentifier: "showBudgetDetail", sender: budget)
       }

       @IBAction func addBudgetTapped(_ sender: UIButton) {
           let newBudget = Budget(category: "", amount: 0.0, period: .weekly, alertEnabled: true, alertThreshold: 0.8, spentAmount: 0.0)
           performSegue(withIdentifier: "showBudgetDetail", sender: newBudget)
       }

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "showBudgetDetail",
              let destinationVC = segue.destination as? BudgetDetailViewController,
              let budget = sender as? Budget {
               destinationVC.budget = budget
               destinationVC.delegate = self
               destinationVC.isNewBudget = (budget.category.isEmpty && budget.amount == 0.0)
           }
       }
   }

   extension BudgetListViewController: BudgetDetailDelegate {
       func didSaveBudget(_ budget: Budget) {
           if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
               budgets[index] = budget
           } else {
               budgets.append(budget)
           }
           tableView.reloadData()
       }

       func didDeleteBudget(_ budget: Budget) {
           budgets.removeAll { $0.id == budget.id }
           tableView.reloadData()
       }
   }

   extension Double {
       var currencyString: String {
           let formatter = NumberFormatter()
           formatter.numberStyle = .currency
           return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
       }
}
