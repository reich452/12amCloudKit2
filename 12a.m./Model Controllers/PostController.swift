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
    
    
    
    
}
