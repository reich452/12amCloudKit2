//
//  FeedTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/6/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {

    fileprivate let presentSignUpSegue =  "presentSignUp"
    fileprivate let showEditProfileSegue = "editProfile"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTimer()
        performInitialAppLogic()
        //        self.refreshControl?.addTarget(self, action: #selector(FeedTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(reloadData), name: Notification.Name("PostCommentsChangedNotification"), object: nil)

        
    }
    
    func setUpTimer() {
        Timer.every(1.second) {
            DispatchQueue.main.async {
                self.title = Date().timeTillString
            }
        }
    }
    
    @objc func reloadData() {
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func swipToRefresh(_ sender: UIRefreshControl, forEvent event: UIEvent) {
        //        handleRefresh(sender)
//        PostController.shared.requestFullSync {
//            DispatchQueue.main.async {
//                self.refreshControl?.endRefreshing()
//                self.tableView.reloadData()
//            }
//        }
    }
    
    @IBAction func imageButtonTapped(_ sender: UIImage) {
        // TODO: Fix the segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToPostDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow, let detailVC = segue.destination as? CommentTableViewController else { return }
            let post = PostController.shared.sortedPosts[indexPath.row]
           detailVC.post = post
        }
        
    }
    
        func handleRefresh(_ refreshControl: UIRefreshControl) {
         //   PostController.shared.requestFullSync()
     //        PostController.sharedController.performFullSync()
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.sortedPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        let post = PostController.shared.sortedPosts[indexPath.row]
        cell.post = post
        
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        if let _ = UserController.shared.currentUser {
            performSegue(withIdentifier: showEditProfileSegue, sender: self)
        } else {
            performSegue(withIdentifier: presentSignUpSegue, sender: self)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addPicButtonTapped()
        
    }
    
    // to here to test photo posting at whatever time
    
    func performInitialAppLogic() {
        UserController.shared.fetchCurrentUser { user in
            if let _ = user {
                return
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.presentSignUpSegue, sender: self)
                }
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
