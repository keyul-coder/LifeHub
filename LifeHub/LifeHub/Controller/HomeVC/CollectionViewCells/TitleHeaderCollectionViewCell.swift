//
//  TitleHeaderCollectionViewCell.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

import UIKit

/// TitleHeaderCollectionViewCell
class TitleHeaderCollectionViewCell: UICollectionReusableView {
    
    /// @IBOutlet(s)
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var parentVC: HomeVC!
    var headerType: HomeSections? {
        didSet {
            titleLabel.text = headerType?.title
        }
    }
}
