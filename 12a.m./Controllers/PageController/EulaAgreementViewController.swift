//
//  EulaAgreementViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/27/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class EulaAgreementViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func iagreeButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toBeRespectfulVC", sender: self)
      
    }
    
    
    // MARK: - Navigation


}
