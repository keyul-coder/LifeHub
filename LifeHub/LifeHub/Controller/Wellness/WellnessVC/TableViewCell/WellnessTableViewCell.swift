//
//  WellnessTableViewCell.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-08.
//

import UIKit

/// WellnessTableViewCell
class WellnessTableViewCell: UITableViewCell {
    
    /// @IBOutlet(s)
    @IBOutlet weak var lblJournalTitle: UILabel!
    @IBOutlet weak var lblTimeStamp: UILabel!
    
    /// Carried Varaible(s)
    weak var parentVC: WellnessVC!
    var model: WellnessDiaryModel! {
        didSet {
            self.lblTimeStamp.text = model.formattedDateString()
            self.lblJournalTitle.text = model.text
        }
    }
}
