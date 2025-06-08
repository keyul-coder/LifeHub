import UIKit

struct GoalItem :Codable{
    let id = UUID()
    let title: String
    let category: String
    let date: Date
    let description: String
}

class Goal: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titletext: UITextField!
    @IBOutlet weak var choosecategory: UIButton!
    @IBOutlet weak var selectdate: UIDatePicker!
    @IBOutlet weak var savebutton: UIButton!
    @IBOutlet weak var desplaydata: UITableView!
    @IBOutlet weak var descriptiontaxt: UITextField!
    
    
    // MARK: - Properties
    private var goals: [GoalItem] = []
    private var selectedCategory: String = "General"
    private let categories = ["Health", "Finance", "Career", "Education", "Personal", "General"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadGoals()
        setupTableView()
        setupTextFields()
        setupCategoryMenu()
    }
    private let goalsKey = "savedGoals"

    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }

    private func loadGoals() {
        if let savedData = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([GoalItem].self, from: savedData) {
            goals = decoded
        }
    }

    // MARK: - Setup
    private func setupUI() {
       // title = "My Goals"
        savebutton.layer.cornerRadius = 8
        savebutton.isEnabled = false
        choosecategory.layer.cornerRadius = 8
        choosecategory.layer.borderWidth = 1
        choosecategory.layer.borderColor = UIColor.systemGray4.cgColor
//  selectdate.minimumDate = Date()
        var config = UIButton.Configuration.filled()
        config.title = "Choose Category"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .systemBackground

        choosecategory.configuration = config

               selectdate.minimumDate = Date()
        
    }
    private func setupCategoryMenu() {
           
            var menuActions: [UIAction] = []
            
            for category in categories {
                let action = UIAction(title: category) { [weak self] _ in
                    self?.selectedCategory = category
                    self?.choosecategory.setTitle("Category: \(category)", for: .normal)
                    self?.validateForm()
                }
                menuActions.append(action)
            }
            
           
            let categoryMenu = UIMenu(title: "Select Category", children: menuActions)
            
           
            choosecategory.menu = categoryMenu
            choosecategory.showsMenuAsPrimaryAction = true
            choosecategory.changesSelectionAsPrimaryAction = true
        }
       
    private func setupTableView() {
        desplaydata.dataSource = self
        desplaydata.delegate = self
        desplaydata.register(UITableViewCell.self, forCellReuseIdentifier: "Data")
        desplaydata.tableFooterView = UIView()
        desplaydata.rowHeight = UITableView.automaticDimension
        desplaydata.estimatedRowHeight = 80
    }
    
    private func setupTextFields() {
        titletext.delegate = self
        descriptiontaxt.delegate = self
        titletext.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    @IBAction func save(_ sender: Any) {
        guard let title = titletext.text, !title.isEmpty else { return }
        
        let newGoal = GoalItem(
            title: title,
            category: selectedCategory,
            date: selectdate.date,
            description: descriptiontaxt.text ?? ""
        )
        
        goals.insert(newGoal, at: 0)
        desplaydata.reloadData()
        clearForm()
    }
    
    // MARK: - Helper Methods
    private func clearForm() {
        titletext.text = ""
        descriptiontaxt.text = ""
        choosecategory.setTitle("Choose Category", for: .normal)
        selectdate.date = Date()
        selectedCategory = "General"
        savebutton.isEnabled = false
    }
    
    private func validateForm() {
        savebutton.isEnabled = !(titletext.text?.isEmpty ?? true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    @objc private func textFieldDidChange() {
        validateForm()
    }
}

// MARK: - UITableView DataSource & Delegate
extension Goal: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Data", for: indexPath)
        let goal = goals[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = goal.title
        content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
        
       
        let secondaryText = """
        \(goal.category) • \(formatDate(goal.date))
        \(goal.description)
        """
        
        content.secondaryText = secondaryText
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            goals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
}

// MARK: - UITextFieldDelegate
extension Goal: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titletext {
            descriptiontaxt.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
