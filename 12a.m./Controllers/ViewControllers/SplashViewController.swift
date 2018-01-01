//
//  SplashViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/28/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class SplashViewController: UITabBarController {
    
    private var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(checkForExistingUser), name: UserController.shared.currnetUserWasSentNotification, object: nil)

    }
    
    @objc func checkForExistingUser() {
        if UserController.shared.currentUser == nil {
            self.performSegue(withIdentifier: "toSignUpVC", sender: self)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let feedTVC = sb.instantiateViewController(withIdentifier: "customTabBar")
            self.window?.rootViewController = feedTVC
            self.window?.makeKeyAndVisible()
        }
    }

}
