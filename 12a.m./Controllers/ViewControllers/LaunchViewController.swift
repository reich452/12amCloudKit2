//
//  LaunchViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/5/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(fetchCurrentUser), name: UserController.shared.currnetUserWasSentNotification, object: nil)
    }
    
    @objc func fetchCurrentUser() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let onboardingSb = UIStoryboard(name: "Onboarding", bundle: nil)
        if UserController.shared.currentUser == nil && (UserDefaults.standard.value(forKey: "login") as? String) == nil {
            let onboardingPG = onboardingSb.instantiateViewController(withIdentifier: "Onboarding")
            self.navigationController?.show(onboardingPG, sender: nil)
            self.present(onboardingPG, animated: true, completion: nil)
           
        } else {
            let feedVC = mainStoryboard.instantiateViewController(withIdentifier: "customTabBar")
            self.navigationController?.show(feedVC, sender: nil)
            self.present(feedVC, animated: true, completion: nil)
        }
    }
    
}
