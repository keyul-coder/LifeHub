//
//  HomeVC.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-02.
//

import UIKit

/// HomeVC
class HomeVC: ParentVC {
    
    /// Varaiable Declaration(s)
    private var viewModel: HomeViewModel = HomeViewModel()
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
        
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
            let _ = segue.destination as! UITabBarController
        } else if segue.identifier == "segueBadgeViewController" {
            let _ = segue.destination as! BadgeViewController
        }
    }
}

// MARK: - UI Related Method(s)
extension HomeVC {

    func prepareUI() {
        
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.arrSections[indexPath.section].cellIdentifier, for: indexPath) as! MainHeaderCollectionViewCell
            cell.parentVC = self
            return cell
        case .feature:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.arrFeatures[indexPath.row].cellIdentifier, for: indexPath) as! FeaturesCell
            cell.tag = indexPath.row
            cell.parentVC = self
            cell.type = self.viewModel.arrFeatures[indexPath.row]
            return cell
        case .progress:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.arrProgressSections[indexPath.row].cellIdentifier, for: indexPath)
            return cell
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
            case .badges:
                self.performSegue(withIdentifier: "segueBadgeViewController", sender: nil)
            }
        case .progress:
            switch self.viewModel.arrProgressSections[indexPath.row] {
            case .waterIntakeCell:
                self.performSegue(withIdentifier: "segueWaterTrackerVC", sender: nil)
            case .taskProgressCell:
                break
            }
        default:
            break
        }
    }
}
