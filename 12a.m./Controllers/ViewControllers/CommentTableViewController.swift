//
//  CommentTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/6/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CloudKit
class CommentTableViewController: UITableViewController, UITextFieldDelegate, CommentUpdatedToDelegate {
    
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
    
    weak var prefetchDataSourece: UITableViewDataSourcePrefetching?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        commentTextField.delegate = self
        updateViews()
        setUI()
        self.tableView.estimatedRowHeight = 220
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PostController.shared.delegate = self
        self.tableView.reloadData()
        PostController.shared.requestFullSync {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateViews() {
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
    func commentsWereAddedTo() {
        let comments = self.post?.comments.count ?? 0
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath.init(row: comments - 1, section: 0)], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        
        guard let post = post,
            let commentText = commentTextField.text, commentText != "" else { return }
        
        PostController.shared.addComment(to: post, commentText: commentText) {
            DispatchQueue.main.async {
                print("\(UserController.shared.currentUser?.username ??? "") added \(commentText) to detail VC")
            }
        }
        commentTextField.text = ""
        self.view.endEditing(true )
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let comments = post?.comments.sorted(by: {$0.timestamp > $1.timestamp } )
        
        return comments?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        guard let comment = self.post?.comments.sorted(by: {$0.timestamp > $1.timestamp })[indexPath.row] else { return UITableViewCell() }
        cell.comment = comment
        
        return cell
    }
    
}


extension CommentTableViewController {
    
    func setUI() {
        self.profileImageView.layer.cornerRadius = profileImageView.layer.frame.height / 2
        self.profileImageView.clipsToBounds = true 
    }
}

extension CommentTableViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(CommentTableViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


