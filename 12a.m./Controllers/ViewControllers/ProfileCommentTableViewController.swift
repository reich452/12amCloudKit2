//
//  ProfileCommentTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/6/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class ProfileCommentTableViewController: UITableViewController, UITextFieldDelegate, ProfileCommentTableViewCellDelegate, CommentUpdatedToDelegate {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    // MARK: - Properties
    var post: Post?
    var comment: Comment?
    
    weak var prefetchDataSourece: UITableViewDataSourcePrefetching?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextField.delegate = self
        hideKeyboard()
        updateViews()
        setUI()
        
        self.tableView.estimatedRowHeight = 220
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PostController.shared.delegate = self
        
        PostController.shared.requestFullSync {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Main
    
    private func updateViews() {
        guard let post = post,
            let date = post.timestamp.formatter,
            let photo = post.photo, let username = post.owner?.username else { return }
        
        let profileImage = post.owner?.photo
        if profileImage == nil {
            self.profileImageView.image = #imageLiteral(resourceName: "avatar")
        } else {
            self.profileImageView.image = post.owner?.photo
        }
        self.usernameLabel.text = username
        self.imageView.image = photo
        self.commentLabel.text = "\(post.text)"
        self.dateLabel.text = date.string(from: post.timestamp)
    }
    
    // MARK: - Delegate
    
   internal func didPressBlockButton(_ sender: ProfileCommentTableViewCell) {
        blockUserActionSheet()
    }
    
   internal func didPressUserInfo(_ sender: ProfileCommentTableViewCell) {
        self.performSegue(withIdentifier: "toPostDetail2", sender: sender)
    }
    @objc func commentsWereAddedTo2() {
        let commentsCount = self.post?.comments.count ?? 0
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath.init(row: commentsCount - 1, section: 0)], with: .automatic)
            print("Comments are\(self.post?.comments.count ??? "") and now \(commentsCount)")
            print("\(UserController.shared.currentUser?.username ??? "") added comment")
        }
    }
    
    internal func commentsWereAddedTo() {
        let commentsCount = self.post?.comments.count ?? 0
        DispatchQueue.main.async {
            //            self.tableView.insertRows(at: [IndexPath.init(row: commentsCount - 1, section: 0)], with: .automatic)
            self.tableView.reloadData()
            print("Comments are\(self.post?.comments.count ??? "") and now \(commentsCount)")
            print("\(UserController.shared.currentUser?.username ??? "") added comment")
        }
    }
    
    private func blockUserActionSheet() {
        let blockUserAlertController = UIAlertController(title: "Block User", message: "Would you like to block this user? \nYou will no longer be able to \nsee their posts or comments", preferredStyle: .actionSheet)
        let blockUserAction = UIAlertAction(title: "Block", style: .default) { (_) in
            self.blockUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        blockUserAlertController.addAction(blockUserAction)
        blockUserAlertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(blockUserAlertController, animated: true, completion: nil)
        }
    }
    
    private func blockUser() {
        guard let ownerReference = self.post?.ownerReference else { return }
        UserController.shared.blockUser(userToBlock: ownerReference) {
            print("Sucessfully blocked user from the Cell")
        }
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toProfileDetailTVC(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toPostDetail2", sender: self)
    }
    
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        
        guard let post = post,
            let commentText = commentTextField.text, commentText != "" else { return }
        
        PostController.shared.addComment(to: post, commentText: commentText) {
            
        }
        commentTextField.text = ""
        self.view.endEditing(true)
    }
    
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let comments = post?.comments.sorted(by: {$0.timestamp > $1.timestamp } )
        print("Aaron's test \(comments?.count ??? "")")
        return comments?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell2", for: indexPath) as? ProfileCommentTableViewCell else { return UITableViewCell() }
        
        guard let comment = self.post?.comments.sorted(by: {$0.timestamp > $1.timestamp })[indexPath.row] else { return UITableViewCell() }
        cell.comment = comment
        cell.delegate = self
        cell.selectedUserDelegate = self
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileDetailVC" {
            guard let destinationVC = segue.destination as? ProfileDetailTableViewController else { return }
            if let selectedCell = sender as? CommentTableViewCell {
                guard let indexPath = tableView.indexPath(for: selectedCell) else { return }
                guard let comment = self.post?.comments[indexPath.row] else { return }
                destinationVC.comment = comment
            }
        } else if segue.identifier == "toPostDetail2" {
            guard let profileDstination = segue.destination as? ProfileDetail2TableViewController else { return }
            guard let post = post else { return }
            profileDstination.post = post
        }
    }
}


extension ProfileCommentTableViewController {
    
    func setUI() {
        self.profileImageView.layer.cornerRadius = profileImageView.layer.frame.height / 2
        self.profileImageView.clipsToBounds = true
    }
}

extension ProfileCommentTableViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ProfileCommentTableViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
