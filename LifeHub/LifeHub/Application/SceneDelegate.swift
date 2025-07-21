//
//  SceneDelegate.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-05-18.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Always show login screen on app launch (logout any existing session)
//        logoutUserOnAppLaunch()
        if let _ = Auth.auth().currentUser?.uid {
            showMainApp()
        } else {
            showLoginScreen()
        }
        window?.makeKeyAndVisible()
    }
    
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController {
            let navigationController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navigationController
        }
    }
    
    func showMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabController = storyboard.instantiateViewController(withIdentifier: "TabController") as? TabController {
            window?.rootViewController = tabController
        }
    }
    
    private func logoutUserOnAppLaunch() {
        // Automatically logout user when app launches
        do {
            try Auth.auth().signOut()
            print("User automatically logged out on app launch")
        } catch let signOutError as NSError {
            print("Error signing out on app launch: \(signOutError)")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Automatically logout user when app goes to background
        logoutUserOnBackground()
    }
    
    private func logoutUserOnBackground() {
        // Logout user when app goes to background
        do {
            try Auth.auth().signOut()
            print("User automatically logged out when app went to background")
        } catch let signOutError as NSError {
            print("Error signing out on background: \(signOutError)")
        }
    }
}

