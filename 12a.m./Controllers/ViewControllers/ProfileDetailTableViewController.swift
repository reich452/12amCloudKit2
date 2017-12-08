//
//  ProfileDetailTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/7/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class ProfileDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var post: Post?
    var comment: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView() {
    
    }

}
