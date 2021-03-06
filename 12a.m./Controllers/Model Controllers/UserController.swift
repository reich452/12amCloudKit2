//
//  UserController.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/27/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import CloudKit
import UIKit
import CoreLocation

class UserController {
    static let shared = UserController()
    
    // MARK: - Properties
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    let currnetUserWasSentNotification = Notification.Name("currentUserWasSet")
   
    var users = [User]()
    var currentUser: User? {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.currnetUserWasSentNotification, object: nil)
            }
        }
    }
    
    init() {
        checkUsersCloudKitAvailablility()
    }
    
    func fetchCurrentUser(completion: @escaping ((User?, _ success: Bool) -> Void) = {_,_  in }) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error { print("Error fetching userID: \(#function) \(error.localizedDescription) & \(error)")
                completion(nil, false)
                return
            }
            guard let recordID = recordID else { return }
            let appleUserRef = CKReference(recordID: recordID, action: .deleteSelf)
            let predicate = NSPredicate(format: "appleUserRef == %@", appleUserRef)
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            self.cloudKitManager.publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("error fethcing user record \(error) & \(error.localizedDescription) \(#function)")
                    let ckAccountStatus = CKAccountStatus.couldNotDetermine
                    self.cloudKitManager.handleCloudKitUnavailable(ckAccountStatus, error: error)
                    completion(nil, false); return
                }
                guard let records = records else {
                    
                    // Send a different notification that will tell the launchscreen to present/segue to the login/signup screen.
                    
                    return }
                let users = records.compactMap { User(cloudKitRecord: $0)}
                let user = users.first
                print("Fetched loged in user \(user?.username ?? "can't fetch user" )")
                // Don't forget to set current user
                self.currentUser = user
                let likedPosts = user?.likedPostRefs
                self.currentUser?.likedPostRefs = likedPosts ?? []
                completion(user, true)
            })
        }
    }
    
    //C
    func checkUsersCloudKitAvailablility() {
        cloudKitManager.checkCloudKitAvailability()
    }
    
    func checkForExistingUserWith(username: String?, completion: @escaping (Bool) -> Void) {
        guard let username = username else { return }
        let predicate = NSPredicate(format: "username ==%@", username)
        
        let query = CKQuery(recordType: username, predicate: predicate)
        self.cloudKitManager.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if records?.count == 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // TODO
    func createUser(with username: String, email: String, profileImage: UIImage, completion: @escaping (_ success: Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { [unowned self] (appleUsersRecordId, error) in
            if let error = error {
                print("Error fetchingUserRcordID \(#function) \(error) & \(error.localizedDescription))")
                completion(false); return
            }
            guard let recordID = appleUsersRecordId,
                let data = UIImageJPEGRepresentation(profileImage, 1.0) else { print("Error creating recordID")
                    completion(false); return
            }
            let blockUserRefs = self.currentUser?.blockUserRefs
            let likedPostRefs = self.currentUser?.likedPostRefs ?? []
            
            let appleUserRef = CKReference(recordID: recordID, action: .deleteSelf)
            let isFavorite: Bool = false
            
            let user = User(username: username, email: email, appleUserRef: appleUserRef, profileImageData: data, blockUserRefs: blockUserRefs, likedPostRefs: likedPostRefs, isFavorite: isFavorite)
            let userRecord = CKRecord(user: user)
            self.cloudKitManager.saveRecord(userRecord, completion: { [unowned self] (record, error) in
                if let error = error {
                    print("Error saing user record \(#file) \(#function) \(error) \(error.localizedDescription)")
                    completion(false); return
                }
                guard let record = record,
                    let currentUser = User(cloudKitRecord: record) else {
                        completion(false); return
                }
                self.currentUser = currentUser
                completion(true)
                // TODO - clean this up
                if error == nil {
                    print("Success creating user \(self.currentUser?.username ??? "")")
                } else {
                    print("Error saving user Rcord \(error?.localizedDescription ?? String("error saving user record"))")
                }
            })
        }
    }
    
    func createUserLocation(with username: String, email: String, profileImage: UIImage, state: String, city: String, country: String, completion: @escaping (_ success: Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { [unowned self] (appleUsersRecordId, error) in
            if let error = error {
                print("Error fetchingUserRcordID \(#function) \(error) & \(error.localizedDescription))")
                completion(false); return
            }
            guard let recordID = appleUsersRecordId, let posts = self.currentUser?.posts,
                let data = UIImageJPEGRepresentation(profileImage, 1.0) else { print("Error creating recordID")
                    completion(false); return
            }
            let blockUserRefs = self.currentUser?.blockUserRefs
            
            let appleUserRef = CKReference(recordID: recordID, action: .deleteSelf)
            let user = User(username: username, email: email, appleUserRef: appleUserRef, profileImageData: data, blockUserRefs: blockUserRefs, posts: posts, city: city, state: state, country: country)
          
            let userRecord = CKRecord(user: user)
            self.cloudKitManager.saveRecord(userRecord, completion: { [unowned self] (record, error) in
                if let error = error {
                    print("Error saing user record \(#file) \(#function) \(error) \(error.localizedDescription)")
                    completion(false); return
                }
                guard let record = record,
                    let currentUser = User(cloudKitRecord: record) else {
                        completion(false); return
                }
                self.currentUser = currentUser
                completion(true)
                // TODO - clean this up
                if error == nil {
                    print("Success creating user \(self.currentUser?.username ??? "")")
                } else {
                    print("Error saving user Rcord \(error?.localizedDescription ?? String("error saving user record"))")
                }
            })
        }
    }
    
    
    //R
    
    //U
    
    func updateCurrentUserWithLocation(_ city: String, state: String, country: String, compleation: @escaping (_ success: Bool) -> Void) {
        guard let currentUser = self.currentUser else { return }
       
        currentUser.city = city
        currentUser.state = state
        currentUser.country = country
        let currentUserRecord = CKRecord(user: currentUser)
        
        self.cloudKitManager.modifyRecords([currentUserRecord], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print(" error modifying curretn user record \(#function) \(error.localizedDescription)")
                compleation(false); return
            } else {
                print("updated user \(currentUser.username)")
            }
            compleation(true)
            
        }
    }
    
    func updateCurrentUser(username: String, email: String, profileImage: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        guard let currentUser = currentUser, let profileImage = profileImage,
            let data = UIImageJPEGRepresentation(profileImage, 1.0) else { print("Something broke \(#function)"); return }
        
        
        currentUser.username = username
        currentUser.email = email
        currentUser.profileImageData = data
        
        let currentUserRecord = CKRecord(user: currentUser)
        self.cloudKitManager.modifyRecords([currentUserRecord], perRecordCompletion: nil) { (_, error) in
            
            if let error = error {
                print("Error updating \(#function) \(error) & \(error.localizedDescription)")
                completion(false); return
            } else {
                print("updated user")
            }
            completion(true)
        }
    }
    
    //D
    
    func blockUser(userToBlock: CKReference, completion: @escaping () -> Void) {
        self.currentUser?.blockUserRefs?.append(userToBlock)
        guard let currentUser = currentUser else { return }
        let record = CKRecord(user: currentUser)
        
        self.cloudKitManager.modifyRecords([record], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                print("Error modifying records \(#function) \(error) \(error.localizedDescription)")
                return
            } else {
                print("User \(currentUser.username) blocked \(userToBlock)")
                completion()
            }
        }
    }
    
    
    
    
}

