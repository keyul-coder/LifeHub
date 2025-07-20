//
//  MoodViewController.swift
//  LifeHub
//
//  Created by Krina Patel on 2025-07-18.
//


import UIKit

struct MoodEntry: Codable {
    let date: Date
    let mood: String
    let thoughts: String
}

class MoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var thoughts: UITextView!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var recordsTableView: UITableView!
    
    @IBOutlet weak var terribleButton: UIButton!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var excellentButton: UIButton!
    
    private var selectedMood: String?
    private let entriesKey = "moodEntries"
    private var entries: [MoodEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadEntries()
    }
    
    private func setupUI() {
        // Configure text view
        thoughts.layer.borderWidth = 1.0
        thoughts.layer.borderColor = UIColor.lightGray.cgColor
        thoughts.layer.cornerRadius = 8.0
        thoughts.text = "Write Here..."
        thoughts.textColor = .lightGray
        thoughts.delegate = self
        
        // Configure save button
        save.layer.cornerRadius = 8.0
        save.isEnabled = false
        
        // Set initial date to today
        date.date = Date()
        
        // Set up mood buttons
        setupMoodButtons()
        
        // Configure table view
        recordsTableView.dataSource = self
        recordsTableView.delegate = self
        recordsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoodCell")
        recordsTableView.layer.cornerRadius = 8
        recordsTableView.tableFooterView = UIView()
        recordsTableView.rowHeight = UITableView.automaticDimension
        recordsTableView.estimatedRowHeight = 80
    }
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoodCell", for: indexPath)
        let entry = entries[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
        Mood: \(entry.mood)
        Date: \(dateFormatter.string(from: entry.date))
        Thoughts: \(entry.thoughts)
        """
        
        return cell
    }
    
    // MARK: - Button Actions
    @IBAction func saved(_ sender: Any) {
        guard let mood = selectedMood else { return }
        
        let newEntry = MoodEntry(
            date: date.date,
            mood: mood,
            thoughts: thoughts.text == "Write Here..." ? "No thoughts" : thoughts.text
        )
        
        saveEntry(newEntry)
        showConfirmation()
    }
    
    @objc private func moodSelected(_ sender: UIButton) {
        let moods = ["Terrible", "Bad", "Neutral", "Good", "Excellent"]
        selectedMood = moods[sender.tag]
        updateMoodSelectionUI(selectedButton: sender)
        save.isEnabled = true
    }
    
    // MARK: - Helper Methods
    private func setupMoodButtons() {
        let buttons = [terribleButton, badButton, neutralButton, goodButton, excellentButton]
        let emojis = ["😭", "😞", "😐", "🙂", "😁"]
        
        for (index, button) in buttons.enumerated() {
            button?.setTitle(emojis[index], for: .normal)
            button?.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            button?.tag = index
            button?.addTarget(self, action: #selector(moodSelected(_:)), for: .touchUpInside)
        }
    }
    
    private func updateMoodSelectionUI(selectedButton: UIButton) {
        let buttons = [terribleButton, badButton, neutralButton, goodButton, excellentButton]
        
        buttons.forEach { button in
            button?.alpha = button == selectedButton ? 1.0 : 0.5
            button?.transform = button == selectedButton ?
                CGAffineTransform(scaleX: 1.2, y: 1.2) :
                CGAffineTransform.identity
        }
    }
    
    private func saveEntry(_ entry: MoodEntry) {
        entries.append(entry)
        recordsTableView.reloadData()
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey),
              let loadedEntries = try? JSONDecoder().decode([MoodEntry].self, from: data) else {
            return
        }
        entries = loadedEntries
        recordsTableView.reloadData()
    }
    
    private func showConfirmation() {
        let alert = UIAlertController(
            title: "Mood Saved!",
            message: "Your mood entry has been recorded.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.resetForm()
        })
        
        present(alert, animated: true)
    }
    
    private func resetForm() {
        selectedMood = nil
        thoughts.text = "Write Here..."
        thoughts.textColor = .lightGray
        date.date = Date()
        save.isEnabled = false
        
        let buttons = [terribleButton, badButton, neutralButton, goodButton, excellentButton]
        buttons.forEach { button in
            button?.alpha = 1.0
            button?.transform = .identity
        }
    }
}

extension MoodViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write Here..." {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write Here..."
            textView.textColor = .lightGray
        }
    }
}
