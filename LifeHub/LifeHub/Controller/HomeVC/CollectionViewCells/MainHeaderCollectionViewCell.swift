//
//  MainHeaderCollectionViewCell.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

import UIKit

class MainHeaderCollectionViewCell: UICollectionViewCell {
    
    /// @IBOutlet(s)
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lblUSerName: UILabel!
    @IBOutlet weak var lblTaksDoneValue: UILabel!
    @IBOutlet weak var lblDaysStreakValue: UILabel!
    @IBOutlet weak var lblWaterIntakePercentageValue: UILabel!
    
    /// Variable Declaration(s)
    
    /// Carried Varaiable(s)
    weak var parentVC: HomeVC!
}
