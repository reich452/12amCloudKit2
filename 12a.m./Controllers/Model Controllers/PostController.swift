//
//  PostController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/4/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CloudKit

extension PostController {
    static let PostChangeNotified = Notification.Name("PostChangeNotified")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
}

class PostController {
    static let shared = PostController()
    let cloudKitManager = CloudKitManager()
    
    // MARK: - Properties
    
    var posts = [Post]() {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: PostController.PostChangeNotified, object: self)
            }
        }
    }
    var comments = [Comment]()
    
    var isSyncing: Bool = false
    
    // MARK: - Delegates
    weak var delegate: CommentUpdatedToDelegate?
    
    var filteredPosts: [Post] {
        
        return self.posts.sorted(by: {$0.timestamp > $1.timestamp } )
    }
    
    var sortedPosts: [Post] {
        
        return self.posts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
    }
    
    //MARK: -Synced functions that will help grab records synced in CloudKit. Saves on data and time.
    
    // Check for specified post and comments
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Post":
            return posts.flatMap { $0 as? CloudKitSyncable }
        case "Comment":
            return comments.flatMap { ($0 as? CloudKitSyncable) }
        default:
            return []
        }
    }
    
    func syncedRecors(ofType type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsyncedRecords(ofType type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { !$0.isSynced }
    }
    
    // MARK: - Main
    
    func createPost(image: UIImage, text: String, completion: @escaping((Post?) -> Void)) {
        
        let username = UserController.shared.currentUser?.username
        guard let data = UIImageJPEGRepresentation(image, 1),
            let currentUser = UserController.shared.currentUser,
            let currentUserRecordID = currentUser.cloudKitRecordID else { print("No current user \(username ?? "nope")"); return }
        
        
        let ownerReference = CKReference(recordID: currentUserRecordID, action: .none)
        let post = Post(photoData: data, text: text, owner: currentUser, ownerReference: ownerReference)
        
        // Adds post to first tvccell
        posts.append(post)
        let record = CKRecord(post)
        
        cloudKitManager.saveRecord(record) { [weak self] (record, error) in
            guard let _ = record else {
                if let error = error {
                    print("Error saving new post to cloudKit: \(#function) \(error) & \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(post)
                return
            }
            self?.posts = [post]
        }
    }
    
    func addComment(to post: Post, commentText: String, completion: @escaping () -> Void)  {
        guard let cloudKitRef = post.cloudKitReference else { return }
        
        guard let currentUser = UserController.shared.currentUser,
        let userRecordID = currentUser.cloudKitRecordID else { return }
        let ckReference = CKReference(recordID: userRecordID, action: .none)
        
        let comment = Comment(text: commentText, post: post, postReference: cloudKitRef, ownerReference: ckReference)
        post.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            if let error = error {
                print("Error saving new comment in cloudKit: \(#function) \(error) & \(error.localizedDescription)")
                completion(); return
            }
            self.delegate?.commentsWereAddedTo()
            completion()
        }
    }
    
    func fetchNewRecors(ofType type: String, completion: @escaping (() -> Void) = { }) {
        
        var referencesToExClude = [CKReference]()
        
        var predicate: NSPredicate?
        if type == "User" {
            predicate = NSPredicate(value: true)
        } else if type == "Post" {
            predicate = NSPredicate(value: true)
        } else if type == "Comment" {
            predicate = NSPredicate(value: true)
        }
        
        referencesToExClude = self.syncedRecors(ofType: type).flatMap { $0.cloudKitReference }
        
        
        guard let predicate2 = predicate else { return }
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate2, recordFetchedBlock: nil) { (records, error) in
            
            if let error = error {
                print("Error fetcing predicte2 \(#function) \(error) \(error.localizedDescription)")
                completion(); return }
            guard let records = records else { completion(); return }
            switch type {
            case User.recordTypeKey:
                let users = records.flatMap { User(cloudKitRecord: $0) }
                UserController.shared.users = users
                completion()
            case Post.recordTypeKey:
                let posts = records.flatMap { Post(ckRecord: $0) }
                self.posts = posts
                // Helps make the user have a stronger relationship with post
                for post in (self.posts) {
                    let users = UserController.shared.users
                    guard let postOwner = users.filter({$0.cloudKitRecordID == post.ownerReference.recordID}).first else { break }
                    
                    post.owner = postOwner
                    
                }
                completion()
            case Comment.recordTypeKey:
                let comments = records.flatMap { Comment(ckRecord: $0) }
                for comment in comments {
                    let postRef = comment.postReference
                    guard let postIndex = self.posts.index(where: {$0.ckRecordID == postRef.recordID } ) else { completion(); return }
                    let post = self.posts[postIndex]
                    post.comments.append(comment)
                    comment.post = post
                    guard let ownerIndex = UserController.shared.users.index(where: { $0.cloudKitRecordID == comment.ownerReference.recordID  })
                        else { break }
                    let user = UserController.shared.users[ownerIndex]
                    comment.owner = user
                }
                self.comments = comments
                completion()
            default:
                print("Cannot fetch records")
                return
            }
        }
    }

    func fetchAllPosts(completion: @escaping (() -> Void)) {
        self.fetchNewRecors(ofType: Post.recordTypeKey) {
            completion()
        }
    }
    
    func performFullSync(completion: @escaping (() -> Void) = { }) {
        isSyncing = true
        
        self.fetchNewRecors(ofType: User.recordTypeKey) { 
            self.fetchNewRecors(ofType: Post.recordTypeKey) {
                self.fetchNewRecors(ofType: Comment.recordTypeKey) {
                    self.isSyncing = false
                    completion()
                }
            }
        }
    }
    
    func requestFullSync(_ completion: (() -> Void)? = nil) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.performFullSync {
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion?()
            })
        }
    }
}




