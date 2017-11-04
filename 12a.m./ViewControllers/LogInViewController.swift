//
//  LogInViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/3/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

enum ButtonState {
    case selected
    case notSelected
}

class LogInViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameUiView: UIView!
    @IBOutlet weak var emailUIView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerUIView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Properties
   private var buttonState: ButtonState = .notSelected
    
    // MARK: - Life Cycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
    }
    
    // MARK: - Actions
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        logInButtonClicked()
    }
}

extension LogInViewController {
    
    // MARK: - Main
    func logInButtonClicked() {
        switch buttonState {
        case .notSelected:
            buttonState = .selected
            
            loginButton.layer.cornerRadius = 8
            loginButton.layer.masksToBounds = true
            loginButton.layer.borderColor = UIColor.primaryAppBlue.cgColor
            loginButton.layer.backgroundColor = UIColor.primaryAppBlue.cgColor
            loginButton.layer.borderWidth = 2
            loginButton.setTitleColor(UIColor.white, for: .normal)
            loginButton.setTitle("Sign Up", for: .normal)
            
        case .selected:
            buttonState = .notSelected
            
            loginButton.layer.cornerRadius = 8
            loginButton.layer.masksToBounds = true
            loginButton.layer.borderColor = UIColor.primaryAppBlue.cgColor
            loginButton.layer.backgroundColor = nil
            loginButton.layer.borderWidth = 2
            loginButton.setTitleColor(UIColor.primaryAppBlue, for: .normal)
            loginButton.setTitle("Log In", for: .normal)
        }
    }
    
    // MARK: - UI
    func setAppearance() {
        self.view.backgroundColor = UIColor.backgroundAPpGrey
        
        headerImageView.image = UIImage(named: "whiteBackground")
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.layer.masksToBounds = true
        headerUIView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        
        profileImageView.image = UIImage(named: "avatar")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.height / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        
        loginButton.layer.cornerRadius = 8
        loginButton.layer.masksToBounds = true
        loginButton.layer.borderColor = UIColor.primaryAppBlue.cgColor
        loginButton.setTitleColor(.primaryAppBlue, for: .normal)
        loginButton.setTitle("LogIn", for: .normal)
        // TODO: - controll button state if new or existing user
    }
}


