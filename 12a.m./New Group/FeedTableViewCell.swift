//
//  FeedTableViewCell.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/6/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var captionTextLabel: UILabel!
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
    }
    @IBAction func blockUserButtonTapped(_ sender: Any) {
    }
    
}
