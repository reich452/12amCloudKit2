//
//  LogInViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/3/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

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
    
    // MARK: - Life Cycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        
    }
}
