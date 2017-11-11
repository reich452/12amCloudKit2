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
    
    private func updateViews() {
        guard let post = post,
            let owner = post.owner,
            let username = post.owner?.username else { return }
        
        profileImageView.image = owner.profileImage
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
