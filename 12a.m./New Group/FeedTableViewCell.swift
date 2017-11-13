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
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    /// At 9:28 the image stopped coming back 
    private func updateViews() {
        guard let post = post,
            let owner = post.owner,
            let username = post.owner?.username else { return }
        
        if profileImageView.image == nil {
            profileImageView.image = #imageLiteral(resourceName: "avatar")
        } else {
            profileImageView.image = owner.photo
        }
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.height / 2
        profileImageView.layer.masksToBounds = true
        postImageButton.imageView?.contentMode = .scaleAspectFill
        postImageButton.setImage(post.photo, for: .normal)
        userNameLabel.text = username
        captionTextLabel.text = post.text
        
    }
    
    
    // MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: UIButton) {
    }
    @IBAction func blockUserButtonTapped(_ sender: Any) {
    }
    
}
