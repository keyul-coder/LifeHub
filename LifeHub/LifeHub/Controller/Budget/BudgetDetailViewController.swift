//
//  BudgetDetailViewController.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-07-05.
//

import UIKit

protocol BudgetDetailDelegate: AnyObject {
    func didSaveBudget(_ budget: Budget)
    func didDeleteBudget(_ budget: Budget)
}

class BudgetDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var addExpense: UIButton!
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var budgetAmountTextField: UITextField!
    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var customPeriodTextField: UITextField!
    @IBOutlet weak var alertEnabledSwitch: UISwitch!
    @IBOutlet weak var alertThresholdSlider: UISlider!
    @IBOutlet weak var alertThresholdLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Properties
    
    var budget: Budget!
    weak var delegate: BudgetDetailDelegate?
    var isNewBudget = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBudgetData()
        setupTextFields()
    }
    
    private func setupUI() {
        title = "Budget Details"
        
        saveButton.layer.cornerRadius = 10
        deleteButton.layer.cornerRadius = 10
        
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        
        // Hide custom period field initially
        customPeriodTextField.isHidden = true
    }
    
    private func loadBudgetData() {
        categoryTextField.text = budget.category
        budgetAmountTextField.text = budget.amount == 0 ? "" : "\(budget.amount)"
        
        // Set time period
        switch budget.period {
        case .weekly:
            timePeriodSegmentedControl.selectedSegmentIndex = 0
        case .monthly:
            timePeriodSegmentedControl.selectedSegmentIndex = 1
        case .custom(let days):
            timePeriodSegmentedControl.selectedSegmentIndex = 2
            customPeriodTextField.text = "\(days)"
            customPeriodTextField.isHidden = false
            
            if budget.alertEnabled && budget.amount > 0 {
                let spentRatio = budget.spentAmount / budget.amount
                if spentRatio >= budget.alertThreshold {
                    showAlert(title: "⚠️ Budget Alert", message: "You've reached \(Int(spentRatio * 100))% of your \(budget.category) budget.")
                }
            }
        }
        
        // Set alert settings
        alertEnabledSwitch.isOn = budget.alertEnabled
        alertThresholdSlider.value = Float(budget.alertThreshold)
        updateAlertThresholdLabel()
        
        // Set progress
        updateProgressUI()
        
        // Hide delete button for new budgets
        deleteButton.isHidden = isNewBudget
    }
    
    private func setupTextFields() {
        categoryTextField.delegate = self
        budgetAmountTextField.delegate = self
        customPeriodTextField.delegate = self
        
        // Add toolbar with Done button to numeric keyboards
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)
        
        budgetAmountTextField.inputAccessoryView = toolbar
        customPeriodTextField.inputAccessoryView = toolbar
    }
    
    private func updateAlertThresholdLabel() {
        let threshold = Int(alertThresholdSlider.value * 100)
        alertThresholdLabel.text = "Alert at \(threshold)% of budget"
    }
    
    private func updateProgressUI() {
        // Safeguard against division by zero or invalid amounts
        guard budget.amount > 0 else {
            progressView.progress = 0
            spentLabel.text = "\(budget.spentAmount.currencyString) of \(budget.amount.currencyString) spent"
            progressLabel.text = "0% of budget used"
            progressView.progressTintColor = .systemBlue
            progressLabel.textColor = .label
            return
        }
        
        let progress = budget.spentAmount / budget.amount
        progressView.progress = Float(progress)
        
        spentLabel.text = "\(budget.spentAmount.currencyString) of \(budget.amount.currencyString) spent"
        
        // Safely convert to percentage
        let percentage = progress.isFinite ? Int(progress * 100) : 0
        progressLabel.text = "\(percentage)% of budget used"
        
        // Change color if over budget
        if progress > 1.0 {
            progressView.progressTintColor = .systemRed
            progressLabel.textColor = .systemRed
        } else if progress > 0.8 {
            progressView.progressTintColor = .systemOrange
            progressLabel.textColor = .systemOrange
        } else {
            progressView.progressTintColor = .systemBlue
            progressLabel.textColor = .label
        }
    }
    
    // MARK: - Actions
    @IBAction func addExpenseTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Expense", message: "Enter the amount to add to \(budget.category)", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Expense amount"
                textField.keyboardType = .decimalPad
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                if let input = alert.textFields?.first?.text,
                   let amount = Double(input), amount > 0 {
                    self.logExpense(amount: amount)
                } else {
                    self.showAlert(title: "Invalid Input", message: "Please enter a valid expense amount.")
                }
            }))
            
            present(alert, animated: true)
    }
    
    @IBAction func timePeriodChanged(_ sender: UISegmentedControl) {
        customPeriodTextField.isHidden = sender.selectedSegmentIndex != 2
    }
    
    @IBAction func alertEnabledChanged(_ sender: UISwitch) {
        alertThresholdSlider.isEnabled = sender.isOn
        alertThresholdLabel.isEnabled = sender.isOn
    }
    
    @IBAction func alertThresholdChanged(_ sender: UISlider) {
        updateAlertThresholdLabel()
    }
    
    @IBAction func saveBudgetTapped(_ sender: UIButton) {
        guard validateInputs() else { return }
        
        // Update budget with form values
        budget.category = categoryTextField.text ?? ""
        budget.amount = budgetAmountTextField.text?.safeDouble() ?? 0.0
        
        switch timePeriodSegmentedControl.selectedSegmentIndex {
        case 0:
            budget.period = .weekly
        case 1:
            budget.period = .monthly
        case 2:
            let days = Int(customPeriodTextField.text ?? "7") ?? 7
            budget.period = .custom(days)
        default:
            break
        }
        
        budget.alertEnabled = alertEnabledSwitch.isOn
        budget.alertThreshold = Double(alertThresholdSlider.value)
        
        delegate?.didSaveBudget(budget)
        dismiss(animated: true)
    }
    
    @IBAction func deleteBudgetTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Budget",
            message: "Are you sure you want to delete this budget?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate?.didDeleteBudget(self.budget)
            self.dismiss(animated: true)
        })
        if budget.alertEnabled && budget.amount > 0 {
               let spentRatio = budget.spentAmount / budget.amount
               if spentRatio >= budget.alertThreshold {
                   showAlert(title: "⚠️ Budget Limit Reached", message: "You've spent \(Int(spentRatio * 100))% of your budget for \(budget.category).")
               }
           }
        present(alert, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation
    
    private func validateInputs() -> Bool {
        guard let category = categoryTextField.text?.trimmingCharacters(in: .whitespaces),
              !category.isEmpty else {
            showAlert(title: "Missing Category", message: "Please enter a budget category")
            return false
        }
        
        guard let amountText = budgetAmountTextField.text?.trimmingCharacters(in: .whitespaces),
              !amountText.isEmpty,
              let amount = Double(amountText),
              amount.isFinite,
              amount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid budget amount greater than 0")
            return false
        }
        
        if timePeriodSegmentedControl.selectedSegmentIndex == 2 {
            guard let customDaysText = customPeriodTextField.text?.trimmingCharacters(in: .whitespaces),
                  !customDaysText.isEmpty,
                  let customDays = Int(customDaysText),
                  customDays > 0 else {
                showAlert(title: "Invalid Period", message: "Please enter a valid number of days (1 or more)")
                return false
            }
        }
        
        return true
    }
    func logExpense(amount: Double) {
        budget.spentAmount += amount
        updateProgressUI() // Update UI
        if budget.alertEnabled && budget.amount > 0 {
            let spentRatio = budget.spentAmount / budget.amount
            if spentRatio >= budget.alertThreshold {
                showAlert(title: "⚠️ Warning", message: "You've exceeded your alert threshold for \(budget.category).")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension String {
    func safeDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: self) {
            return number.doubleValue.isFinite ? number.doubleValue : nil
        }
        return nil
    }
    
    func safeInt() -> Int? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        if let number = formatter.number(from: self) {
            return number.intValue
        }
        return nil
    }
}
extension BudgetDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == categoryTextField {
            budgetAmountTextField.becomeFirstResponder()
        } else if textField == budgetAmountTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == budgetAmountTextField {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Allow empty (for deleting)
            if newText.isEmpty { return true }
            
            // Allow only numbers and one decimal point
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            guard allowedCharacters.isSuperset(of: characterSet) else { return false }
            
            // Only one decimal point allowed
            if string == ".", currentText.contains(".") { return false }
            
            // Limit to 2 decimal places
            if let dotIndex = currentText.range(of: ".")?.upperBound {
                let decimalDigits = currentText.distance(from: dotIndex, to: currentText.endIndex)
                if decimalDigits >= 2 && range.location > currentText.distance(from: currentText.startIndex, to: dotIndex) {
                    return false
                }
            }
            
            return true
        } else if textField == customPeriodTextField {
            // Only allow whole numbers for days
            let allowedCharacters = CharacterSet(charactersIn: "0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}

