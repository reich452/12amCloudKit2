//
//  EulaAgreementViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/27/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class EulaAgreementViewController: UIViewController {
    @IBOutlet weak var agreementButton: UIButton!
    
    // MARK: - Properties
    var didAgree: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions

    @IBAction func clearButtonTapped(_ sender: UIButton) {
       allert()
    }
    
    @IBAction func iagreeButtonTapped(_ sender: Any) {
        updateAgreement()
    }
    
    // MARK: - Main
    
    func updateAgreement() {
        if didAgree  {
            UserDefaults.standard.set(didAgree, forKey: "login")
            performSegue(withIdentifier: "toBeRespectfulVC", sender: self)
        } else {
            didAgree = false
            allert()
        }
    }
    
    func allert() {
        showAlertMessage(titleStr: "You Must Agree To Continue",
                         messageStr: "Read the terms and agree before using this app. Everyone's gotta do it!")
    }
}
