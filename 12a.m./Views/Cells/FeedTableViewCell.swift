//
//  FeedTableViewCell.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/6/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

protocol FeedTableViewCellDelegate: class {
    func didTapCommentButton(_ sender: FeedTableViewCell)
    func didTapProfileButton(_ sender: FeedTableViewCell)
    func didTapBlockUserButton(_ sender: FeedTableViewCell)
}


class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var captionTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    // MARK: - Propoerties
    weak var delegate: FeedTableViewCellDelegate?
    weak var selectedProfileDelegate: FeedTableViewCellDelegate?
    weak var blockUserDelegate: FeedTableViewCellDelegate?
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let post = post,
            let owner = post.owner,
            let username = post.owner?.username else { return }
        
        if profileImageView.image == nil {
            profileImageView.image = #imageLiteral(resourceName: "avatar")
        } else {
            profileImageView.image = owner.photo
        }
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = profileImageView.layer.frame.height / 2
        self.profileImageView.layer.masksToBounds = true
        self.postImageButton.imageView?.contentMode = .scaleAspectFill
        self.postImageButton.setImage(post.photo, for: .normal)
        self.userNameLabel.text = username
        self.captionTextLabel.text = post.text
        self.timestampLabel.text = "\(post.timestamp.timePosted?.string(from: post.timestamp) ??? "12:00 A.M.")"
    }
    
    
    // MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.didTapCommentButton(self)
        }
    }
    @IBAction func blockUserButtonTapped(_ sender: Any) {
        if let blockUserDelegate = self.blockUserDelegate {
            blockUserDelegate.didTapBlockUserButton(self)
        }
//        self.blockUserActionSheet()
    }
    @IBAction func profileButtonTapped(_ sender: Any) {
        if let selectedProfileDelegate = self.selectedProfileDelegate {
            selectedProfileDelegate.didTapProfileButton(self)
        }
    }
    
}

extension FeedTableViewCell {
    
    // MARK: - Block Users
    
    func blockUser() {
        guard let post = post else { return }
        let ownerReference = post.ownerReference
        UserController.shared.blockUser(userToBlock: ownerReference) {
        
        }
    }
    
    func blockUserActionSheet() {
        let blockUserAlertController = UIAlertController(title: "Block User", message: "Would you like to block this user? \nYou will no longer be able to \nsee their posts or comments", preferredStyle: .actionSheet)
        let blockUserAction = UIAlertAction(title: "Block", style: .default) { (_) in
            self.blockUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        blockUserAlertController.addAction(blockUserAction)
        blockUserAlertController.addAction(cancelAction)

    }
}

extension UIView {
    var parentViewController: CommentTableViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is CommentTableViewController {
                return parentResponder as! CommentTableViewController!
            }
        }
        return nil
    }
}






