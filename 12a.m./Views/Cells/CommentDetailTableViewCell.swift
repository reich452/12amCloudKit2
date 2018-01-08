//
//  CommentDetailTableViewCell.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/6/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit
protocol CommentDetailTableViewCellDelegate: class {
    func didPressBlockButton(_ sender: CommentDetailTableViewCell)
    func didPressUserInfo(_ sender: CommentDetailTableViewCell)
}

class CommentDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var blockUsersButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    // MARK: - Delegate
    weak var delegate: CommentDetailTableViewCellDelegate?
    weak var selectedUserDelegate: CommentDetailTableViewCellDelegate?
    
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func blockUsersButtonTapped(_ sender: UIButton) {
        delegate?.didPressBlockButton(self)
        
    }
    
    @IBAction func userInfoButtonTapped(_ sender: Any) {
        if let selectedUserDelegate = self.selectedUserDelegate {
            selectedUserDelegate.didPressUserInfo(self)
        }
        
    }
    private func updateViews() {
        guard let comment = comment,
            let userName = comment.owner?.username,
            let profileData = comment.owner?.profileImageData,
            let profileImage = UIImage(data: profileData)
            else { return }
        
        self.userNameLabel.text = userName
        self.commentTextLabel.text = comment.text
        self.profileImageView.image = profileImage
        self.profileImageView.layer.cornerRadius =  profileImageView.layer.frame.height / 2
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.clipsToBounds = true
    }
}
