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
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.setUpAppearance()
    }
    
    var comment: Comment?
    
   private func setUpView() {
        guard let owner = comment?.owner else { return }
        self.usernameLabel.text = owner.username
        self.profileImageView.image = owner.photo
    }
    
   private func setUpAppearance() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.height / 2 
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        
    }

}
