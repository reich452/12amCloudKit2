//
//  PostController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/4/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

extension PostController {
    static let PostChangeNotified = Notification.Name("PostChangeNotified")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
}

class PostController {
    static let shared = PostController()
    let cloudKitManager = CloudKitManager()
    
    // MARK: - Properties
    
    var comment: Comment?
    var post: Post?
    var comments = [Comment]()
    var isSyncing: Bool = false
    
    var posts = [Post]() {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: PostController.PostChangeNotified, object: self)
                //                nc.post(name: PostController.PostCommentsChangedNotification, object: self)
            }
        }
    }
    
    // MARK: - Delegates
    weak var delegate: CommentUpdatedToDelegate?
    weak var likedPostDelegate: LikedPostUpdatedToDelegate?
    
    var filteredPosts: [Post] {
        
        return self.posts.sorted(by: {$0.timestamp > $1.timestamp } )
    }
    
    var sortedUserPosts: [Post] {
        guard let ownerPosts = comment?.owner?.posts else { return [] }
        return ownerPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
    }
    
    
    
    //MARK: -Synced functions that will help grab records synced in CloudKit. Saves on data and time.
    
    // Check for specified post and comments
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Post":
            return posts.compactMap { $0 as? CloudKitSyncable }
        case "Comment":
            return comments.compactMap { ($0 as? CloudKitSyncable) }
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
        guard let data = UIImageJPEGRepresentation(image, 0.8),
            let currentUser = UserController.shared.currentUser,
            let currentUserRecordID = currentUser.cloudKitRecordID else { print("No current user \(username ?? "nope")"); return }
        
        
        let ownerReference = CKReference(recordID: currentUserRecordID, action: .deleteSelf)
        let post = Post(photoData: data, text: text, owner: currentUser, ownerReference: ownerReference)
        
        // Adds post to first tvccell
        posts.append(post)
        let record = CKRecord(post)
        
        cloudKitManager.saveRecord(record) { [unowned self] (record, error) in
            guard let _ = record else {
                if let error = error {
                    print("Error saving new post to cloudKit: \(#function) \(error) & \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(post)
                return
            }
            self.posts = [post]
        }
    }
    
    func addComment(to post: Post, commentText: String, completion: @escaping () -> Void)  {
        
        guard let cloudKitRef = post.cloudKitReference else { return  }
        
        guard let currentUser = UserController.shared.currentUser,
            let userRecordID = currentUser.cloudKitRecordID else { return }
        let ckReference = CKReference(recordID: userRecordID, action: .deleteSelf)
        
        let comment = Comment(text: commentText, post: post, postReference: cloudKitRef, ownerReference: ckReference)
        comment.owner = currentUser // Aaron is the man
        post.comments.append(comment)
        
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            if let error = error {
                print("Error saving new comment in cloudKit: \(#function) \(error) & \(error.localizedDescription)")
                completion(); return
            }
            DispatchQueue.main.async {
                self.delegate?.commentsWereAddedTo()
                comment.ckRecordID = record?.recordID
                completion()
            }
        }
    }
    
    func fetchNewRecors(ofType type: String, completion: @escaping (() -> Void) = { }) {
        
        
        var referencesToExClude = [CKReference]()
        
        var predicate: NSPredicate?
        if type == "User" {
            predicate = NSPredicate(value: true)
        } else if type == "Post" {
            guard let user = UserController.shared.currentUser,
                let blockUserRefs = user.blockUserRefs, type != "User" else { return }
            predicate = NSPredicate(format: "NOT(ownerRef IN %@)", blockUserRefs)
        } else if type == "Comment" {
            guard let user = UserController.shared.currentUser,
                let blockUserRefs = user.blockUserRefs, type != "User" else { return }
            predicate = NSPredicate(format: "NOT(ownerReference IN %@)", blockUserRefs)
        }
        
        referencesToExClude = self.syncedRecors(ofType: type).compactMap { $0.cloudKitReference }
        let _ = referencesToExClude.count
        
        guard let predicate2 = predicate else { return }
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate2, recordFetchedBlock: nil) { (records, error) in
            
            if let error = error {
                print("Error fetcing predicte2 \(#function) \(error) \(error.localizedDescription)")
                completion(); return }
            guard let records = records else { completion(); return }
            switch type {
            case User.recordTypeKey:
                let users = records.compactMap { User(cloudKitRecord: $0) }
                UserController.shared.users = users
                completion()
            case Post.recordTypeKey:
                let posts = records.compactMap { Post(ckRecord: $0) }
                self.posts = posts
                // Helps make the user have a stronger relationship with post
                for post in (self.posts) {
                    let users = UserController.shared.users
                    guard let postOwner = users.filter({$0.cloudKitRecordID == post.ownerReference.recordID}).first else { break }
                    post.owner = postOwner
                    post.owner?.posts = posts
                    let ownerPosts = postOwner.posts?.filter{$0.ownerReference == post.ownerReference}
                    post.owner?.posts = ownerPosts
                    
                }
                completion()
            case Comment.recordTypeKey:
                let comments = records.compactMap { Comment(ckRecord: $0) }
                let dispatchGroup = DispatchGroup()
                for comment in comments {
                    dispatchGroup.enter()
                    let postRef = comment.postReference
                    guard let postIndex = self.posts.index(where: {$0.ckRecordID == postRef.recordID } ) else { completion(); return }
                    let post = self.posts[postIndex]
                    post.comments.append(comment)
                    comment.post = post
                    guard let ownerIndex = UserController.shared.users.index(where: { $0.cloudKitRecordID == comment.ownerReference.recordID  })
                        else { break }
                    let user = UserController.shared.users[ownerIndex]
                    comment.owner = user
                    dispatchGroup.leave()
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
    
    
    // MARK: - Subscriptions
    // Follow Users
    
    func subscribeToNewUsers(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        let preidcate = NSPredicate(value: true)
        
        cloudKitManager.subscribe(User.recordTypeKey, predicate: preidcate, subscriptionID: "subscribeToUser", contentAvailable: true, options: .firesOnRecordCreation) { (subscription, error) in
            
            if let error = error {
                print("Error subscribing to User: \(#function) \(error.localizedDescription) \(error)")
                completion(false, error)
            }
            
            let success = subscription != nil
            completion(success, error)
        }
    }
    
    
    func checkSubscriptionFor(likedPosts post: Post, completion: @escaping (_ subscribed: Bool) -> Void) {
        guard let postOwner = post.owner,
            let postRecordName = postOwner.cloudKitRecordID?.recordName else { return }
        guard !postOwner.hasCheckedFavoriteStatus else { completion(postOwner.hasCheckedFavoriteStatus); return }
        cloudKitManager.fetchSubscription(postRecordName) { (subscription, error) in
            if let error = error,
                let ckError = error as? CKError,
                ckError.code != .unknownItem {
                print("Error checking liked subscription for \(#function): \(error) \(error.localizedDescription)")
                completion(false);  return
            }
            let subscribed = subscription != nil
            post.owner?.isFavorite = subscribed
            completion(subscribed)
        }
    }
    
    
    func addSubscriptionTo(postsForUser user: User,
                           alertBody: String?,
                           completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) = { _,_ in }) {
        
        guard let recordID = user.cloudKitRecordID else { fatalError("Unable to create CloudKit reference for subscription.") }
        
        //        let predicate = NSPredicate(format: "username == %@", user.username)
        
        let predicate = NSPredicate(format: "ownerRef == %@", argumentArray: [recordID])
        
        user.isFollowing = true // Set this back to false later if subscribing fails
        
        cloudKitManager.subscribe(Post.recordTypeKey, predicate: predicate, subscriptionID: recordID.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: ["ownerRef"], options: .firesOnRecordCreation) { (subscription, error) in
            
            if let error = error {
                print("Error adding sbuscription: \(#function) \(error.localizedDescription) \(error)")
                completion(false, error); return
            }
            
            let success = subscription != nil
            user.isFollowing = success
            completion(success, nil)
        }
    }
    
    
    func removeSubscriptionTo(postsForUser user: User,
                              completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) = { _,_ in }) {
        
        guard let subscriptionID = user.cloudKitRecordID?.recordName else {
            completion(true, nil)
            return
        }
        
        user.isFollowing = false // Set this back to true later if subscribing fails
        
        cloudKitManager.unsubscribe(subscriptionID) { (subscriptionID, error) in
            let success = subscriptionID != nil && error == nil
            user.isFollowing = !success
            completion(success, error)
        }
    }
    
    // MARK: - Subscriptions for liking
    
    func checkSubscriptionTo(postsForUser user: User, completion: @escaping (_ subscribed: Bool) -> Void) {
        
        guard !user.hasCheckedFollowStatus else { completion(user.isFollowing); return }
        guard let subscriptionID = user.cloudKitRecordID?.recordName else {
            user.isFollowing = false
            completion(false)
            return
        }
        
        cloudKitManager.fetchSubscription(subscriptionID) { (subscription, error) in
            if let error = error,
                let ckError = error as? CKError,
                ckError.code != .unknownItem {
                print("Error checking follow status subscription for \(user): \(error)")
                return
            }
            
            user.hasCheckedFollowStatus = true
            let subscribed = subscription != nil
            user.isFollowing = subscribed
            completion(subscribed)
        }
    }
    
    func addSubscriptionToLikedPost(forPost post: Post, alertBody: String?, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) = {_,_ in }) {
        guard let postRecordID = post.ckRecordID else {
           fatalError("Unable to create CloudKit reference for liking subscription.")
        }
    
        
        let predicate = NSPredicate(format: "ownerRef == %@", argumentArray: [postRecordID])
    
        cloudKitManager.subscribe(Post.recordTypeKey, predicate: predicate, subscriptionID: postRecordID.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: nil, options: [.firesOnRecordCreation, .firesOnRecordUpdate]) { (subscription, error) in
            
            let success = subscription != nil
            post.owner?.isFavorite = success
            completion(success, error)
            guard let likedPostRefs = post.owner?.likedPostRefs else { return }
            self.updateRecord(post: post, likedPosts: likedPostRefs, completion: { (success) in
                if !success {
                    print("Error Updating users liked post")
                }
            })
        }
    }

    func removeSubscriptionTo(usersForLiked post: Post,
                              completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) = { _,_ in }) {

        guard let subscriptionID = post.ckRecordID?.recordName else {
            completion(true, nil)
            return
        }
        post.owner?.isFavorite = false // Set this back to true later if subscribing fails
        guard let index = post.owner?.likedPostRefs.index(of: post.ownerReference) else { completion(false, nil); return }
        post.owner?.likedPostRefs.remove(at: index)
        guard let likedPostArray = post.owner?.likedPostRefs else { completion(false, nil); return }

        cloudKitManager.unsubscribe(subscriptionID) { (subscriptionID, error) in
            let success = subscriptionID != nil && error == nil
            post.owner?.isFavorite = !success
            post.owner?.likedPostRefs = likedPostArray
            completion(success, error)
        }
    }
    
    func updateRecord(post: Post, likedPosts: [CKReference], completion: @escaping (_ success: Bool) -> Void) {
        guard let user = UserController.shared.currentUser else { completion(false); return }
        
        let likedRef = post.ownerReference
        var likedPostRefs = likedPosts
        likedPostRefs.append(likedRef)
        
        let currentUserRecord = CKRecord(user: user)
        
        cloudKitManager.modifyRecords([currentUserRecord], perRecordCompletion: nil) { (_, error) in
            
            if let error = error {
                print("Error modifyingRecords: \(#function) \(error.localizedDescription) \(error)")
                completion(false); return
            }
            post.owner?.likedPostRefs = likedPostRefs
            completion(true)
        }
    }
    
}




