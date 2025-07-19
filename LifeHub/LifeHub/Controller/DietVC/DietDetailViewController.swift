//
//  DietDetailViewController.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-06-19.
//

import UIKit

class DietDetailViewController: UIViewController {
    
    @IBOutlet weak var vwDifficulty: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var difficultyValueLabel: UILabel!
    @IBOutlet weak var caloriesValueLabel: UILabel!
    @IBOutlet weak var meal1Label: UILabel!
    @IBOutlet weak var meal2Label: UILabel!
    @IBOutlet weak var meal3Label: UILabel!
    @IBOutlet weak var benefit1Label: UILabel!
    @IBOutlet weak var benefit2Label: UILabel!
    @IBOutlet weak var benefit3Label: UILabel!
    @IBOutlet weak var lblRecipe: UILabel!
    @IBOutlet weak var lblIngridents: UILabel!
    
    var dietPlan: DietPlan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        populateData()
    }
    
    private func setupView() {
        // Setup navigation
        navigationItem.title = dietPlan?.name ?? "Diet Details"
        
        // Enable multiline labels
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        meal1Label.numberOfLines = 0
        meal2Label.numberOfLines = 0
        meal3Label.numberOfLines = 0
        
        benefit1Label.numberOfLines = 0
        benefit2Label.numberOfLines = 0
        benefit3Label.numberOfLines = 0
        
        vwDifficulty.layer.cornerRadius = 10
    }
    
    private func populateData() {
        guard let dietPlan = dietPlan else { return }
        
        // Basic info
        descriptionLabel.text = dietPlan.description
        categoryLabel.text = formatCategory(dietPlan.category)
        
        // Stats
        durationValueLabel.text = dietPlan.duration
        difficultyValueLabel.text = dietPlan.difficulty
        caloriesValueLabel.text = dietPlan.calories
        
        // Sample meals
        if dietPlan.sampleMeals.count >= 3 {
            meal1Label.text = dietPlan.sampleMeals[0]
            meal2Label.text = dietPlan.sampleMeals[1]
            meal3Label.text = dietPlan.sampleMeals[2]
        }
        
        // Benefits
        if dietPlan.benefits.count >= 3 {
            benefit1Label.text = dietPlan.benefits[0]
            benefit2Label.text = dietPlan.benefits[1]
            benefit3Label.text = dietPlan.benefits[2]
        }
        lblRecipe.text = dietPlan.recipes.name
        lblIngridents.text = "" // Clear previous content

        for ingredient in dietPlan.recipes.ingredients {
            lblIngridents.text! += "• \(ingredient)\n"
        }
    }
    
    private func formatCategory(_ category: String) -> String {
        switch category {
        case "all":
            return "General"
        case "muscles":
            return "Muscle Building"
        case "balanced":
            return "Balanced Diet"
        case "keto":
            return "Ketogenic"
        default:
            return category.capitalized
        }
    }
}
