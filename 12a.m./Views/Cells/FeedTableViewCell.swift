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
    func didTapReportUserButton(_ sender: FeedTableViewCell)
    func didTapFollowUserButton(_ sender: FeedTableViewCell)
    func didTapLikeUsersPostButton(_ sender: FeedTableViewCell)
    func didTapLikePostButton(_ sender: FeedTableViewCell)
}

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var captionTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Propoerties
    weak var delegate: FeedTableViewCellDelegate?
    weak var selectedProfileDelegate: FeedTableViewCellDelegate?
    weak var blockUserDelegate: FeedTableViewCellDelegate?
    weak var reportUserDelegate: FeedTableViewCellDelegate?
    weak var followUserDelegate: FeedTableViewCellDelegate?
    weak var likeUsersPostDelegate: FeedTableViewCellDelegate?
    weak var likePostDelegate: FeedTableViewCellDelegate?
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let post = post,
            let owner = post.owner,
            let postCkref = post.cloudKitReference,
            let username = post.owner?.username else { return }
        
        
        if profileImageView.image == nil {
            profileImageView.image = #imageLiteral(resourceName: "avatar")
        } else {
            profileImageView.image = owner.photo
        }
        if owner.isFollowing {
            followButton.setTitle("Following", for: .normal)
        } else {
            followButton.setTitle("Follow", for: .normal)
        }
    
        owner.likedPostRefs.contains(postCkref) ? likeButton.setImage(#imageLiteral(resourceName: "filledHeart"), for: .normal) : likeButton.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
            
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
        if let delegate = delegate {
            delegate.didTapCommentButton(self)
        }
    }
    @IBAction func blockUserButtonTapped(_ sender: Any) {
        if let blockUserDelegate = blockUserDelegate {
            blockUserDelegate.didTapBlockUserButton(self)
        }
        if let reportUserDelegate = reportUserDelegate {
            reportUserDelegate.didTapReportUserButton(self)
        }

    }
    @IBAction func profileButtonTapped(_ sender: Any) {
        if let selectedProfileDelegate = selectedProfileDelegate {
            selectedProfileDelegate.didTapProfileButton(self)
        }
    }
    @IBAction func followButtonTapped(_ sender: Any) {
        if let followUserDelegate = followUserDelegate {
            followUserDelegate.didTapFollowUserButton(self)
        }
    }
    @IBAction func likeButtonTapped(_ sender: Any) {
        if let didLikePostDelegate = likePostDelegate {
            didLikePostDelegate.didTapLikePostButton(self)
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
                return parentResponder as! CommentTableViewController?
            }
        }
        return nil
    }
}






