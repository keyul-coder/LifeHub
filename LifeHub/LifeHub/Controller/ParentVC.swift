//
//  ParentVC.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-02.
//

import UIKit

/// ParentVC
class ParentVC: UIViewController {
    
    /// @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parentPrepareUI()
    }
}

// MARK: - UI Related Method(s)
extension ParentVC {
    
    func parentPrepareUI() {
        print(self.classForCoder)
        self.hidesBottomBarWhenPushed = true
    }
}
