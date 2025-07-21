//
//  DietPlan.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-06-19.
//

import Foundation

struct DietPlan {
    let id: Int
    let name: String
    let category: String
    let description: String
    let duration: String
    let difficulty: String
    let calories: String
    let sampleMeals: [String]
    let benefits: [String]
    let recipes: Recipe
}

struct Recipe {
    let name: String
    let ingredients: [String]
}

// Sample data
class DietPlanData {
    static let shared = DietPlanData()
    
    let dietPlans = [
        DietPlan(
            id: 1,
            name: "Mediterranean Diet",
            category: "balanced",
            description: "Heart-healthy eating plan based on traditional foods from Mediterranean countries. This diet emphasizes whole foods and healthy fats.",
            duration: "longterm lifestyle",
            difficulty: "easy",
            calories: "1800",
            sampleMeals: [
                "• Greek salad with olive oil",
                "• Grilled salmon with vegetables",
                "• Whole grain pasta"
            ],
            benefits: [
                "✓ Weight management",
                "✓ Brain health",
                "✓ Heart health"
            ],
            recipes:
                Recipe(
                    name: "Mediterranean Grilled Salmon",
                    ingredients: [
                        "4 salmon fillets (6oz each)",
                        "2 tbsp olive oil",
                        "1 lemon (juiced)"
                    ]
                )
        ),
        DietPlan(
            id: 2,
            name: "Keto Diet",
            category: "keto",
            description: "High-fat, low-carb diet that puts your body into ketosis for weight loss and energy.",
            duration: "3-6 months",
            difficulty: "hard",
            calories: "1600",
            sampleMeals: [
                "• Avocado and eggs",
                "• Grilled chicken with broccoli",
                "• Salmon with asparagus"
            ],
            benefits: [
                "✓ Rapid weight loss",
                "✓ Mental clarity",
                "✓ Reduced appetite"
            ],
            recipes:
                Recipe(
                    name: "Keto Cauliflower Mac and Cheese",
                    ingredients: [
                        "1 large cauliflower head, cut into florets",
                        "1 cup heavy cream",
                        "2 cups cheddar cheese, shredded"
                    ]
                )
        ),
        DietPlan(
            id: 3,
            name: "High Protein Diet",
            category: "muscles",
            description: "Protein-rich diet designed to build and maintain muscle mass while supporting metabolism.",
            duration: "ongoing",
            difficulty: "moderate",
            calories: "2000",
            sampleMeals: [
                "• Protein smoothie with berries",
                "• Grilled chicken breast",
                "• Greek yogurt with nuts"
            ],
            benefits: [
                "✓ Muscle building",
                "✓ Fat burning",
                "✓ Increased metabolism"
            ],
            recipes:
                Recipe(
                    name: "High-Protein Chicken Quinoa Bowl",
                    ingredients: [
                        "6oz chicken breast",
                        "1 cup cooked quinoa",
                        "1 cup broccoli florets"
                    ]
                )
        ),
        DietPlan(
            id: 4,
            name: "Paleo Diet",
            category: "balanced",
            description: "Based on foods presumed to be available to Paleolithic humans. Focuses on whole, unprocessed foods.",
            duration: "lifestyle",
            difficulty: "moderate",
            calories: "1700",
            sampleMeals: [
                "• Grilled meat with vegetables",
                "• Fresh fruit and nuts",
                "• Sweet potato with herbs"
            ],
            benefits: [
                "✓ Natural nutrition",
                "✓ Weight control",
                "✓ Improved digestion"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 5,
            name: "DASH Diet",
            category: "balanced",
            description: "Dietary approach to stop hypertension. Emphasizes fruits, vegetables, and low-fat dairy.",
            duration: "permanent",
            difficulty: "easy",
            calories: "1900",
            sampleMeals: [
                "• Oatmeal with berries",
                "• Lean turkey sandwich",
                "• Grilled fish with quinoa"
            ],
            benefits: [
                "✓ Lower blood pressure",
                "✓ Heart health",
                "✓ Weight management"
            ],
            recipes:
                Recipe(
                    name: "DASH Diet Salmon with Quinoa",
                    ingredients: [
                        "4 salmon fillets",
                        "1 cup quinoa",
                        "2 cups low-sodium vegetable broth"
                    ]
                )
        ),
        DietPlan(
            id: 6,
            name: "Intermittent Fasting",
            category: "weight",
            description: "Eating pattern that cycles between periods of fasting and eating. Popular for weight loss.",
            duration: "flexible",
            difficulty: "moderate",
            calories: "varies",
            sampleMeals: [
                "• Black coffee (fasting)",
                "• Large balanced lunch",
                "• Moderate dinner"
            ],
            benefits: [
                "✓ Weight loss",
                "✓ Improved insulin sensitivity",
                "✓ Cellular repair"
            ],
            recipes:
                Recipe(
                    name: "IF Breaking Fast Salad",
                    ingredients: [
                        "6oz grilled chicken breast",
                        "3 cups mixed greens",
                        "1 avocado, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 7,
            name: "Vegetarian Diet",
            category: "balanced",
            description: "Plant-based diet that excludes meat and focuses on fruits, vegetables, grains, and plant proteins.",
            duration: "lifestyle",
            difficulty: "moderate",
            calories: "1700",
            sampleMeals: [
                "• Lentil soup with whole grain bread",
                "• Chickpea curry with rice",
                "• Vegetable stir-fry with tofu"
            ],
            benefits: [
                "✓ Lower risk of heart disease",
                "✓ Better weight management",
                "✓ Reduced environmental impact"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 8,
            name: "Vegan Diet",
            category: "balanced",
            description: "Strict plant-based diet that excludes all animal products including dairy and eggs.",
            duration: "lifestyle",
            difficulty: "hard",
            calories: "1800",
            sampleMeals: [
                "• Avocado toast with nutritional yeast",
                "• Quinoa salad with roasted vegetables",
                "• Black bean burgers with sweet potato fries"
            ],
            benefits: [
                "✓ Lower cholesterol levels",
                "✓ Reduced risk of certain cancers",
                "✓ Ethical food choices"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 9,
            name: "Low-Carb Diet",
            category: "weight",
            description: "Diet that restricts carbohydrates, focusing on proteins and healthy fats for weight loss.",
            duration: "3-12 months",
            difficulty: "moderate",
            calories: "1500",
            sampleMeals: [
                "• Scrambled eggs with spinach",
                "• Bunless burger with avocado",
                "• Zucchini noodles with meatballs"
            ],
            benefits: [
                "✓ Effective weight loss",
                "✓ Reduced blood sugar levels",
                "✓ Improved triglyceride levels"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced",
                        "1 onion, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 10,
            name: "Atkins Diet",
            category: "keto",
            description: "Low-carb, high-protein diet that progresses through four phases of carb reintroduction.",
            duration: "6-12 months",
            difficulty: "hard",
            calories: "1400",
            sampleMeals: [
                "• Bacon and eggs",
                "• Steak with buttered vegetables",
                "• Cheese and nut platter"
            ],
            benefits: [
                "✓ Rapid initial weight loss",
                "✓ Reduced cravings",
                "✓ Improved metabolic markers"
            ],
            recipes:
                Recipe(
                    name: "High-Protein Chicken Quinoa Bowl",
                    ingredients: [
                        "6oz chicken breast",
                        "1 cup cooked quinoa",
                        "1 cup broccoli florets"
                    ]
                )
        ),
        DietPlan(
            id: 11,
            name: "Zone Diet",
            category: "balanced",
            description: "Diet that balances protein, carbs and fat in a 30-40-30 ratio for optimal hormone balance.",
            duration: "ongoing",
            difficulty: "moderate",
            calories: "1600",
            sampleMeals: [
                "• Grilled chicken with brown rice and vegetables",
                "• Turkey chili with beans",
                "• Salmon with quinoa and asparagus"
            ],
            benefits: [
                "✓ Balanced energy levels",
                "✓ Reduced inflammation",
                "✓ Sustainable weight management"
            ],
            recipes:
                Recipe(
                    name: "Keto Cauliflower Mac and Cheese",
                    ingredients: [
                        "1 large cauliflower head, cut into florets",
                        "1 cup heavy cream",
                        "2 cups cheddar cheese, shredded"
                    ]
                )
        ),
        DietPlan(
            id: 12,
            name: "South Beach Diet",
            category: "weight",
            description: "Three-phase diet that starts with strict carb restriction then gradually reintroduces healthy carbs.",
            duration: "3-6 months",
            difficulty: "moderate",
            calories: "1500",
            sampleMeals: [
                "• Vegetable omelet",
                "• Grilled fish with salad",
                "• Lean beef with roasted vegetables"
            ],
            benefits: [
                "✓ Heart-healthy approach",
                "✓ Teaches healthy eating habits",
                "✓ Sustainable results"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 13,
            name: "Flexitarian Diet",
            category: "balanced",
            description: "Mostly vegetarian diet that occasionally includes meat or fish in moderation.",
            duration: "lifestyle",
            difficulty: "easy",
            calories: "1800",
            sampleMeals: [
                "• Veggie burger with sweet potato fries",
                "• Chicken stir-fry with brown rice",
                "• Lentil soup with whole grain bread"
            ],
            benefits: [
                "✓ Flexible approach",
                "✓ Health benefits of vegetarianism",
                "✓ Easier to maintain long-term"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 14,
            name: "Whole30",
            category: "balanced",
            description: "30-day elimination diet that cuts out sugar, alcohol, grains, legumes, soy and dairy.",
            duration: "30 days",
            difficulty: "hard",
            calories: "1700",
            sampleMeals: [
                "• Scrambled eggs with avocado",
                "• Grilled chicken with roasted vegetables",
                "• Beef stew with compliant ingredients"
            ],
            benefits: [
                "✓ Identifies food sensitivities",
                "✓ Resets eating habits",
                "✓ Reduces inflammation"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 15,
            name: "Weight Watchers",
            category: "weight",
            description: "Point-based system that assigns values to foods to help with portion control and healthy choices.",
            duration: "ongoing",
            difficulty: "easy",
            calories: "varies",
            sampleMeals: [
                "• Oatmeal with fruit (low points)",
                "• Grilled chicken salad",
                "• Vegetable stir-fry with lean protein"
            ],
            benefits: [
                "✓ Flexible food choices",
                "✓ Community support",
                "✓ Teaches portion control"
            ],
            recipes:
                Recipe(
                    name: "Keto Cauliflower Mac and Cheese",
                    ingredients: [
                        "1 large cauliflower head, cut into florets",
                        "1 cup heavy cream",
                        "2 cups cheddar cheese, shredded"
                    ]
                )
        ),
        DietPlan(
            id: 16,
            name: "High-Calorie Muscle Gain",
            category: "muscles",
            description: "A high-protein, high-calorie diet designed to help build muscle mass effectively.",
            duration: "3-6 months",
            difficulty: "moderate",
            calories: "3000+",
            sampleMeals: [
                "• Scrambled eggs with cheese & whole wheat toast",
                "• Chicken breast with rice & avocado",
                "• Protein shake with peanut butter & banana"
            ],
            benefits: [
                "✓ Promotes muscle growth",
                "✓ Increases strength & endurance",
                "✓ Healthy weight gain"
            ],
            recipes:
                Recipe(
                    name: "High-Protein Chicken Quinoa Bowl",
                    ingredients: [
                        "6oz chicken breast",
                        "1 cup cooked quinoa",
                        "1 cup broccoli florets"
                    ]
                )
        ),
        DietPlan(
            id: 17,
            name: "Bulking Diet",
            category: "muscles",
            description: "A structured diet focused on consuming more calories than you burn to gain muscle mass.",
            duration: "3-12 months",
            difficulty: "moderate",
            calories: "3500+",
            sampleMeals: [
                "• Oatmeal with nuts, honey & protein powder",
                "• Beef steak with mashed potatoes & veggies",
                "• Cottage cheese with almonds before bed"
            ],
            benefits: [
                "✓ Maximizes muscle gains",
                "✓ Supports intense workouts",
                "✓ Prevents fat accumulation"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 18,
            name: "Healthy Weight Gain",
            category: "weight",
            description: "Balanced diet with nutrient-dense foods to help underweight individuals gain weight safely.",
            duration: "ongoing",
            difficulty: "easy",
            calories: "2500+",
            sampleMeals: [
                "• Whole milk smoothie with oats & berries",
                "• Salmon with quinoa & olive oil dressing",
                "• Greek yogurt with granola & honey"
            ],
            benefits: [
                "✓ Healthy calorie surplus",
                "✓ Nutrient-rich foods",
                "✓ Sustainable weight gain"
            ],
            recipes:
                Recipe(
                    name: "Paleo Beef and Vegetable Stir-Fry",
                    ingredients: [
                        "1 lb grass-fed beef strips",
                        "2 bell peppers, sliced",
                        "1 zucchini, sliced"
                    ]
                )
        ),
        DietPlan(
            id: 19,
            name: "Athlete's Mass Diet",
            category: "muscles",
            description: "High-energy diet for athletes looking to increase muscle mass and performance.",
            duration: "ongoing",
            difficulty: "hard",
            calories: "4000+",
            sampleMeals: [
                "• 6-egg omelet with whole grain toast",
                "• Grilled chicken with sweet potatoes & greens",
                "• Mass gainer shake with almond butter"
            ],
            benefits: [
                "✓ Fuels intense training",
                "✓ Optimizes recovery",
                "✓ Lean muscle growth"
            ],
            recipes:
                Recipe(
                    name: "High-Protein Chicken Quinoa Bowl",
                    ingredients: [
                        "6oz chicken breast",
                        "1 cup cooked quinoa",
                        "1 cup broccoli florets"
                    ]
                )
        ),
        DietPlan(
            id: 20,
            name: "Clean Bulk Diet",
            category: "muscles",
            description: "Focuses on quality calories to minimize fat gain while increasing muscle mass.",
            duration: "4-8 months",
            difficulty: "moderate",
            calories: "2800-3200",
            sampleMeals: [
                "• Protein pancakes with maple syrup",
                "• Turkey breast with brown rice & broccoli",
                "• Casein protein pudding before sleep"
            ],
            benefits: [
                "✓ Lean muscle development",
                "✓ Minimal fat gain",
                "✓ Balanced macronutrients"
            ],
            recipes:
                Recipe(
                    name: "High-Protein Chicken Quinoa Bowl",
                    ingredients: [
                        "6oz chicken breast",
                        "1 cup cooked quinoa",
                        "1 cup broccoli florets"
                    ]
                )
        )
    ]
    
    func getDietPlans(for category: String) -> [DietPlan] {
        if category == "all" {
            return dietPlans
        }
        return dietPlans.filter { $0.category == category }
    }
}
