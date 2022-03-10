//
//  AppDelegate.swift
//  MyMovieMandiri
//
//  Created by Iskandar Herputra Wahidiyat on 10/03/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        showMainController()
        
        return true
    }
    
    //MARK: - Setup
    @objc private func showMainController() {
        if self.window == nil {
            self.window = UIWindow()
        }
        
        let landingPageVC: UIViewController = HomeViewController()
        let navigationController: UINavigationController = UINavigationController(rootViewController: landingPageVC)
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}
