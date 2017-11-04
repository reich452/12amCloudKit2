//
//  TestLogInViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/3/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class TestLogInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var signUpButtonTapped: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(segueToWelcomVC), name: UserController.shared.currnetUserWasSentNotification, object: nil)

    }
    
    // MARK: - Actions
    
    
    @IBAction func LoginButtonTapped(_ sender: UIButton) {
        setUPSingUpButton()
    }

    
    // MARK: - Main
    
   @objc func segueToWelcomVC() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toWelcomVC", sender: self)
        }
    }
    
    func setUPSingUpButton() {
        guard UserController.shared.currentUser == nil,
        let username = userNameTextField.text, username != "",
            let email = emailTextField.text, email != "" else { segueToWelcomVC(); return }
        
        if UserController.shared.currentUser == nil {
            signUpButtonTapped.titleLabel?.text = "sign up"
        } else {
            signUpButtonTapped.titleLabel?.text = "log in"
        }

        UserController.shared.createUser(with: username, email: email) { (user) in
            if let user = user {
                print("\(user.username) was created")
            } else {
                DispatchQueue.main.async {
                    self.presentSimpleAlert(title: "No iCloud account", message: "Please sing into iCloud")
                }
                return
            }
        }
    }
    
    func presentSimpleAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dissmissAction = UIAlertAction(title: "Dissmiss", style: .cancel, handler: nil)
        alert.addAction(dissmissAction)
        self.present(alert, animated: true, completion: nil)
    }
}
