//
//  CommentTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/6/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class CommentTableViewController: UITableViewController, UITextFieldDelegate, CommentUpdatedToDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Properties
    var post: Post?
    weak var prefetchDataSourece: UITableViewDataSourcePrefetching?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        commentTextField.delegate = self
        updateViews()
        
        self.tableView.estimatedRowHeight = 200
        
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
            let photo = post.photo else { return }
        
        self.imageView.image = photo
        self.commentLabel.text = "\(post.text)"
        self.dateLabel.text = date.string(from: post.timestamp)
    }
    
    // MARK: - Delegate
    func commentsWereAddedTo() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        
        guard let post = post,
            let commentText = commentTextField.text, commentText != "" else { return }
        
        PostController.shared.addComment(to: post, commentText: commentText) {
            DispatchQueue.main.async {
                print("\(post.owner?.username ?? "") added \(commentText) to detail VC")
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
