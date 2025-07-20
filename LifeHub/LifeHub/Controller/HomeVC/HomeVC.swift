//
//  HomeVC.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-02.
//

import UIKit
import CoreData

/// HomeVC
class HomeVC: ParentVC {
    
    /// Varaiable Declaration(s)
     var viewModel: HomeViewModel = HomeViewModel()
    @IBOutlet weak var lblWaterIntakeValue: UILabel!
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWaterIntakeData()
        fetchTodayTasks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Refresh data when returning from other screens
        fetchTodayTasks()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "segueWellnessVC" {
            let _ = segue.destination as! WellnessVC
        } else if segue.identifier == "segueWaterTrackerVC" {
            let _ = segue.destination as! WaterTrackerVC
        } else if segue.identifier == "segueTaskViewController" {
            let _ = segue.destination as! TaskViewController
        } else if segue.identifier == "segueGoal" {
            let _ = segue.destination as! Goal
        } else if segue.identifier == "segueQuotesTabBar" {
            let _ = segue.destination as! UINavigationController
        }
    }
}

// MARK: - UI Related Method(s)
extension HomeVC {

    func prepareUI() {
    }
    
    func fetchWaterIntakeData() {
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            viewModel.intakeRecords = try context.fetch(request)
            collectionView.reloadData()
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    func fetchTodayTasks() {
        // Load tasks from UserDefaults (since ToDoTask is a struct, not Core Data)
        if let data = UserDefaults.standard.data(forKey: "SavedTasks"),
           let allTasks = try? JSONDecoder().decode([ToDoTask].self, from: data) {
            
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            viewModel.todayTasks = allTasks.filter { task in
                let taskDate = Calendar.current.startOfDay(for: task.date)
                return taskDate >= today && taskDate < tomorrow
            }
        } else {
            viewModel.todayTasks = []
        }
        collectionView.reloadData()
    }
    
    
}


// MARK: - UI Related Method(s)
extension HomeVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.arrSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.viewModel.arrSections[section] {
        case .feature:
            return self.viewModel.arrFeatures.count
        case .progress:
            return self.viewModel.arrProgressSections.count
        case .mainHeader:
            return 1
       
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.viewModel.arrSections[indexPath.section] {
        case .mainHeader:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: viewModel.arrSections[indexPath.section].cellIdentifier,
                for: indexPath) as! MainHeaderCollectionViewCell
            cell.parentVC = self
            cell.configure()
            return cell
            
        case .feature:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.arrFeatures[indexPath.row].cellIdentifier, for: indexPath) as! FeaturesCell
            cell.tag = indexPath.row
            cell.parentVC = self
            cell.type = self.viewModel.arrFeatures[indexPath.row]
            return cell
        case .progress:
            if self.viewModel.arrProgressSections[indexPath.row].cellIdentifier == "cellWaterIntake" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.arrProgressSections[indexPath.row].cellIdentifier, for: indexPath) as! WaterIntakeCell
                cell.configure(with: viewModel.intakeRecords.reduce(0) { $0 + Int($1.amount) })
                return cell
            } else if self.viewModel.arrProgressSections[indexPath.row].cellIdentifier == "cellTaskProgress" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.arrProgressSections[indexPath.row].cellIdentifier, for: indexPath) as! TaskProgressCell
                cell.configure(with: viewModel.todayTasks)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.arrProgressSections[indexPath.row].cellIdentifier, for: indexPath)
                return cell
            }
       
            
            
    }
        
}
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellHeaderTitle", for: indexPath) as! TitleHeaderCollectionViewCell
            sectionHeader.parentVC = self
            sectionHeader.headerType = self.viewModel.arrSections[indexPath.section]
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = collectionView.frame.width
        switch self.viewModel.arrSections[indexPath.section] {
        case .feature:
            width -= 32
            return CGSize(width: (width - 2) / 2, height: 88)
        case .progress:
            return CGSize(width: width, height: 118)
        case .mainHeader:
            return CGSize(width: width, height: 180)
       
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        return CGSize(width: width, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch self.viewModel.arrSections[section] {
        case .feature:
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print(#function)
        switch self.viewModel.arrSections[indexPath.section] {
        case .feature:
            switch self.viewModel.arrFeatures[indexPath.row] {
            case .wellness:
                self.performSegue(withIdentifier: "segueWellnessVC", sender: nil)
            case .tasks:
                self.performSegue(withIdentifier: "segueTaskViewController", sender: nil)
            case .habits:
                self.performSegue(withIdentifier: "segueGoal", sender: nil)
            case .quotes:
                self.performSegue(withIdentifier: "segueQuotesTabBar", sender: nil)
            case .diet:
                self.performSegue(withIdentifier: "segueDietViewController", sender: nil)
            case .badges:
                self.performSegue(withIdentifier: "segueBadgeViewController", sender: nil)
            }
        case .progress:
            switch self.viewModel.arrProgressSections[indexPath.row] {
            case .waterIntakeCell:
                self.performSegue(withIdentifier: "segueWaterTrackerVC", sender: nil)
            case .taskProgressCell:
                self.performSegue(withIdentifier: "segueTaskViewController", sender: nil)
            }
        default:
            break
        }
    }
}
