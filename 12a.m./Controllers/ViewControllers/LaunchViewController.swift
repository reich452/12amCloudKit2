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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if UserController.shared.currentUser == nil {
            let singUpVC = storyboard.instantiateViewController(withIdentifier: "signUpVC")
            self.navigationController?.show(singUpVC, sender: nil)
            self.present(singUpVC, animated: true, completion: nil)
           
        } else {
            let feedVC = storyboard.instantiateViewController(withIdentifier: "customTabBar")
            self.navigationController?.show(feedVC, sender: nil)
            self.present(feedVC, animated: true, completion: nil)
        }
    }
}
