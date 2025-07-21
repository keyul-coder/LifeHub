//
//  TabController.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-02.
//

import UIKit

/// TabController
class TabController: UITabBarController {
    
    /// View Life Cycle(s)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
    }
}

// MARK: - UI Related Method(s)
extension TabController {
    
    func prepareUI() {
        print(self.classForCoder)
        self.delegate = self
        
        // Add Settings tab
    }
}

// MARK: - UITabBarControllerDelegate
extension TabController: UITabBarControllerDelegate {
    
   func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
       print(#function)
    }
}
