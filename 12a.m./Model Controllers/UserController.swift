//
//  UserController.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/27/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import CloudKit
import UIKit

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
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(completion: @escaping ((User?) -> Void) = {_ in }) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error { print("Error fetching userID: \(#function) \(error.localizedDescription) & \(error)")
                completion(nil)
                return
            }
            guard let recordID = recordID else { return }
            let appleUserRef = CKReference(recordID: recordID, action: .none)
            let predicate = NSPredicate(format: "appleUserRef == %@", appleUserRef)
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            self.cloudKitManager.publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("eerror fethcing user record \(error) & \(error.localizedDescription) \(#function)")
                    completion(nil); return
                }
                guard let records = records else { return }
                let users = records.flatMap { User(cloudKitRecord: $0)}
                let user = users.first
                print("Fetched loged in user \(user?.username ?? "" )")
                // Don't forget to set current user 
                self.currentUser = user
                completion(user)
            })
        }
    }
    
    //C
    func createUser(with username: String, email: String, profileImage: UIImage, completion: @escaping (_ success: Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUsersRecordId, error) in
            if let error = error {
                print("Error fetchingUserRcordID \(#function) \(error) & \(error.localizedDescription))")
                completion(false); return
            }
            guard let recordID = appleUsersRecordId, let data = UIImageJPEGRepresentation(profileImage, 0.8) else { print("Error creating recordID")
                completion(false); return
            }
            let appleUserRef = CKReference(recordID: recordID, action: .deleteSelf)
            let user = User(username: username, email: email, appleUserRef: appleUserRef, profileImageData: data)
            let userRecord = CKRecord(user: user)
            self.cloudKitManager.saveRecord(userRecord, completion: { (record, error) in
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
                    print("Success creating user")
                } else {
                    print("Error saving user Rcord \(error?.localizedDescription ?? String("error saving user record"))")
                }
            })
        }
    }
    
    //R
    
    //U
    func updateCurrentUser(username: String, email: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let currentUser = currentUser else { return }
        
        currentUser.username = username
        currentUser.email = email
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
}

