//
//  WaterTrackerVC.swift
//  LifeHub
//
//  Created by Smit Patel  on 07/06/25.
//

import UIKit
import FSCalendar
import CoreData

class WaterTrackerVC: UIViewController {
    
    // MARK: - Outlets -
    @IBOutlet weak var constCalendarHeight: NSLayoutConstraint!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var waterProgressView: WaterProgressView!
    @IBOutlet weak var lblAmountLabel: UILabel!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var btnDrink: UIButton!
    
    // MARK: - Properties
    private var selectedDate = Date()
    private var intakeRecords: [WaterIntake] = []
    private var filteredEntries: [WaterIntake] {
        intakeRecords.filter {
            Calendar.current.isDate($0.timestamp ?? Date(), inSameDayAs: selectedDate)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        fetchIntakeRecords()
    }
    
    // MARK: - Configuration
    private func configureView() {
        view.backgroundColor = .white
        title = "Water Tracker"
        setupCalendar()
        setupProgressView()
        setupHistoryTableView()
        setupDrinkButton()
        updateProgress()
    }
    
    private func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.setScope(.week, animated: false)
        calendar.placeholderType = .none
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.select(selectedDate)
    }
    
    private func setupProgressView() {
        lblAmountLabel.font = .boldSystemFont(ofSize: 24)
        lblAmountLabel.textAlignment = .center
        lblAmountLabel.text = "0 ml"
        
        dailyGoalLabel.font = .systemFont(ofSize: 14)
        dailyGoalLabel.textColor = .gray
        dailyGoalLabel.textAlignment = .center
        dailyGoalLabel.text = "Daily goal: 2,500 ml"
    }
    
    private func setupHistoryTableView() {
        tblHistory.delegate = self
        tblHistory.dataSource = self
        tblHistory.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupDrinkButton() {
        btnDrink.setTitle("Drink (200 ml)", for: .normal)
        btnDrink.backgroundColor = .systemBlue
        btnDrink.setTitleColor(.white, for: .normal)
        btnDrink.layer.cornerRadius = 12
    }
    
    //MARK: - Action Methods -
    @IBAction func btnDrinkTapped(_ sender: UIButton) {
        saveWaterIntake(amount: 200)
    }
    
    // MARK: - Core Data
    private func saveWaterIntake(amount: Int) {
        let context = CoreDataStack.shared.context
        let intake = WaterIntake(context: context)
        intake.amount = Int32(amount)
        intake.timestamp = Date()
        CoreDataStack.shared.saveContext()
        fetchIntakeRecords()
    }
    
    private func fetchIntakeRecords() {
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            intakeRecords = try context.fetch(request)
            tblHistory.reloadData()
            updateProgress()
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    private func updateProgress() {
        let total = filteredEntries.reduce(0) { $0 + Int($1.amount) }
        let goal: CGFloat = 2500
        lblAmountLabel.text = "\(total) ml"
        DispatchQueue.main.async {
            self.waterProgressView.setProgress(CGFloat(total) / goal)
        }
    }
}

//MARK: - UITableview Delegate & Datasource Methods-
extension WaterTrackerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let entry = filteredEntries[indexPath.row]
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        if let time = entry.timestamp {
            cell.textLabel?.text = "\(Int(entry.amount)) ml at \(formatter.string(from: time))"
        }
        return cell
    }
}

//MARK: - FSCalendar Delegate & Datasource Method s-
extension WaterTrackerVC: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        fetchIntakeRecords()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.constCalendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}
