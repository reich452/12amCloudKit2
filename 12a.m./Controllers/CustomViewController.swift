//
//  CustomViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/18/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class CustomViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        customTabBar()
        self.tabBar.barTintColor = UIColor.clear
    }
    
    
    func customTabBar() {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard1.instantiateViewController(withIdentifier: "feedTVC")
        navigationController.title = "Home"
        navigationController.tabBarItem.image = #imageLiteral(resourceName: "homeIcon")
        
        let storyboard2 = UIStoryboard(name: "Main", bundle: nil)
        let updateProfileVC = storyboard2.instantiateViewController(withIdentifier: "updateProfileVC")
        updateProfileVC .title = "Profile"
        updateProfileVC.tabBarItem.image = #imageLiteral(resourceName: "profileIcon")
        updateProfileVC.title = "Profile"
        updateProfileVC.tabBarItem.image = #imageLiteral(resourceName: "profileIcon")
        
        viewControllers = [navigationController, updateProfileVC]
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.rgb(229, green: 231, blue: 235).cgColor
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        
    }
    
}
