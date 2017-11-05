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
    
    var posts = [Post]()
    var comments = [Comment]()
    var isSyncing: Bool = false
    
    var sortedPosts: [Post] {
        
        return self.posts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
    }
    
    func createPost(image: UIImage, text: String, completion: @escaping((Post?) -> Void)) {
        guard let data = UIImageJPEGRepresentation(image, 1),
            let currentUser = UserController.shared.currentUser, let currentUserRecordID = currentUser.cloudKitRecordID else { return }
        
        let ownerReference = CKReference(recordID: currentUserRecordID, action: .none)
        let post = Post(photoData: data, text: text, owner: currentUser, ownerReference: ownerReference)
        
        // Adds post to first tvccell
        posts.insert(post, at: 0)
        let record = CKRecord(post)
        
        cloudKitManager.saveRecord(record) { (record, error) in
            if let error = error {
                print("Error saving new post to cloudKit: \(#function) \(error) & \(error.localizedDescription)")
                completion(nil); return
            }
            completion(post)
        }
    }
    
    func addComment(to post: Post, commentText: String, completion: @escaping () -> Void)  {
        guard let cloudKitRef = post.cloudKitReference else { return }
        
        let comment = Comment(text: commentText, post: post, postReference: cloudKitRef, ownerReference: post.ownerReference)
        post.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            if let error = error {
                print("Error saving new comment in cloudKit: \(#function) \(error) & \(error.localizedDescription)")
                completion(); return
            }
            comment.ckRecordID = record?.recordID
            completion()
        }
        DispatchQueue.main.async {
            let nc = NotificationCenter.default
            nc.post(name: PostController.PostCommentsChangedNotification, object: post)
        }
    }
    
    func fetchNewRecors(ofType type: String, completion: @escaping (() -> Void) = {  }) {
        
        var predicate: NSPredicate?
        if type == "User" {
            predicate = NSPredicate(value: true)
        } else if type == "Post" {
           predicate = NSPredicate(value: true)
        } else if type == "Comment" {
            predicate = NSPredicate(value: true)
        }
        
        // TODO: - handel block users and Syncing
        
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
                for post in self.posts {
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
                return
            }
        }
    }
    
    
}
