//
//  FeedTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/6/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController, FeedTableViewCellDelegate {
 
    fileprivate let presentSignUpSegue =  "presentSignUp"
    fileprivate let showEditProfileSegue = "editProfile"
    
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amLabel: UILabel!
    @IBOutlet weak var openImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTimer()
        setUpAppearance()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(reloadData), name: PostController.PostChangeNotified, object: nil)
        
        PostController.shared.requestFullSync { 
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.reloadData()
    }
    
    // MARK: - Properties
    var post: Post?
    
   private func setUpTimer() {
        Timer.every(1.second) {
            DispatchQueue.main.async { [weak self] in
                self?.timeLabel.text = Date().timeTillString
                self?.timeLabel.textColor = UIColor.digitalBlue
            }
        }
    }
    
    @objc func reloadData() {
        tableView.reloadData()
    }
    
    // MARK: - Delegate
   internal func didTapCommentButton(_ sender: FeedTableViewCell) {
        
        self.performSegue(withIdentifier: "feedToPostDetail", sender: sender)
    }
    
   internal func didTapProfileButton(_ sender: FeedTableViewCell) {
        self.performSegue(withIdentifier: "feedToProfileDetail", sender: sender)
    }
   
    internal func didTapBlockUserButton(_ sender: FeedTableViewCell) {
        blockUserActionSheet()
    }
    
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
        self.present(blockUserAlertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    
    @IBAction func swipToRefresh(_ sender: UIRefreshControl, forEvent event: UIEvent) {
        PostController.shared.requestFullSync { [unowned self] in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
 
    @IBAction func addButtonTapped(_ sender: Any) {
        self.addPicButtonTapped()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        //   PostController.shared.requestFullSync()
        //        PostController.sharedController.performFullSync()
        refreshControl.tintColor = UIColor.refreshControllGreen
        refreshControl.backgroundColor = UIColor.refreshControllGreen
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.filteredPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? FeedTableViewCell else { return UITableViewCell() }
        
        let post = PostController.shared.filteredPosts[indexPath.row]
        cell.post = post
        cell.delegate = self
        cell.selectedProfileDelegate = self
        cell.blockUserDelegate = self
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToPostDetail" {
            guard let detailTVC = segue.destination as? CommentTableViewController else { return }
            if let selectedCell = sender as? FeedTableViewCell {
                guard let indexPath = tableView.indexPath(for: selectedCell) else { return }
                let post = PostController.shared.filteredPosts[(indexPath.row)]
                detailTVC.post = post
            }
        } else if segue.identifier == "feedToProfileDetail" {
            guard let profileDetailTVC = segue.destination as? ProfileDetail2TableViewController else { return }
            if let selectedCell = sender as? FeedTableViewCell {
                guard let indexPath = tableView.indexPath(for: selectedCell) else { return }
                let post = PostController.shared.filteredPosts[(indexPath.row)]
                profileDetailTVC.post = post
            }
        }
    }
    
    func addPicButtonTapped() {
        
        guard let isMidnight = TimeTracker.shared.isMidnight else { return }
        
        if isMidnight {
            
            if UserController.shared.currentUser != nil {
                
                let cameraOrCancelAlertController = UIAlertController(title: "Add Photo", message: "Take a photo to post", preferredStyle: .alert)
                let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
                    self.performSegue(withIdentifier: "toCamera", sender: self) }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                cameraOrCancelAlertController.addAction(cameraAction)
                cameraOrCancelAlertController.addAction(cancelAction)
                present(cameraOrCancelAlertController, animated: true, completion: nil)
                
            } else {
                let noUserAlertController = UIAlertController(title: "User needed", message: "In order to post photos, please log in", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                noUserAlertController.addAction(dismissAction)
                present(noUserAlertController, animated: true, completion: nil)
            }
            
        } else {
            let notMidnightAlertController = UIAlertController(title: "Can't Post photos until midnight", message: "Post photos between 12AM and 1AM", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            notMidnightAlertController.addAction(dismissAction)
            present(notMidnightAlertController, animated: true, completion: nil) ; return
        }
    }
}

extension FeedTableViewController {
    
    func setUpAppearance() {
        
        let backgorundImage =  #imageLiteral(resourceName: "12AMClock")
        let imageView = UIImageView(image: backgorundImage)
        imageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = imageView
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        imageView.clipsToBounds = true
        
        if Date().isInMidnightHour {
            self.openImageView.image = #imageLiteral(resourceName: "openSign")
        } else  {
            self.openImageView.image = #imageLiteral(resourceName: "openInSign")
        }
    }
}




