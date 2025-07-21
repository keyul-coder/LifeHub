//
//  TabController.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-02.
//

import UIKit
import FirebaseAuth

/// TabController
class TabController: UITabBarController {
    
    /// View Life Cycle(s)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
        self.setupLogoutButton()
    }
    
    private func setupLogoutButton() {
        // Add logout button to navigation bar if needed
        // This can be customized based on your app's design
    }
    
    func logout() {
        // Firebase Logout
        do {
            try Auth.auth().signOut()
            // Navigate back to login screen
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController {
                let navigationController = UINavigationController(rootViewController: loginVC)
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = navigationController
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// MARK: - UI Related Method(s)
extension TabController {
    
    func prepareUI() {
        print(self.classForCoder)
        self.delegate = self
    }
}

// MARK: - UITabBarControllerDelegate
extension TabController: UITabBarControllerDelegate {
    
   func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
       print(#function)
    }
}
