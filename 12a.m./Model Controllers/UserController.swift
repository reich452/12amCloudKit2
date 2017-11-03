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
    static let userController = UserController()
    
    // MARK: - Properties
    let cloudKitManager = CloudKitManager()
    
    var users = [User]()
    var currentUser: User?
    
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error { print("Error fetching user: \(error.localizedDescription) \(error)")}
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
                completion(user)
            })
        }
    }
    
    //C
    func createUser(with username: String, email: String, completion: @escaping (User?) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUsersRecordId, error) in
            if let error = error {
                print("Error fetchingUserRcordID \(#file) \(#function) \(error) & \(error.localizedDescription))")
                completion(nil)
                return
            }
            guard let recordID = appleUsersRecordId else { print("Error creating recordID")
                completion(nil); return
            }
            let appleUserRef = CKReference(recordID: recordID, action: .deleteSelf)
            let user = User(username: username, email: email, appleUserRef: appleUserRef)
            let userRecord = CKRecord(user: user)
            self.cloudKitManager.saveRecord(userRecord, completion: { (record, error) in
                if let error = error {
                    print("Error saing user record \(#file) \(#function) \(error) \(error.localizedDescription)")
                    completion(nil); return
                }
                guard let record = record,
                    let currentUser = User(cloudKitRecord: record) else {
                        completion(nil); return
                }
                self.currentUser = currentUser
                completion(currentUser)
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
                print("Error updating \(error) & \(error.localizedDescription)")
                completion(false); return
            }
            completion(true)
        }
    }
    
    //D
}

