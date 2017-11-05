//
//  User.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/26/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CloudKit

class User {
    
    static let recordTypeKey = "User"
    fileprivate let usernameKey = "username"
    fileprivate let emailKey = "email"
    fileprivate let appleUserRefKey = "appleUserRef"
    fileprivate let imageKey = "image"
    fileprivate let blockUserRefKey = "blockUserRef"
    fileprivate let accessTokenKey = "acessToken"
    
    var username: String
    var email: String
    var profileImage: UIImage?
    var cloudKitRecordID: CKRecordID?
    let appleUserRef: CKReference
    
    init(username: String, email: String, appleUserRef: CKReference) {
        self.username = username
        self.email = email
        self.appleUserRef = appleUserRef
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let username = cloudKitRecord[usernameKey] as? String,
            let email = cloudKitRecord[emailKey] as? String,
            let appleUserRef = cloudKitRecord[appleUserRefKey] as? CKReference else { return nil }
        
        self.username = username
        self.email = email
        self.appleUserRef = appleUserRef
        self.cloudKitRecordID = cloudKitRecord.recordID
    
    }
}

extension CKRecord {
    convenience init(user: User) {
        let recordID = user.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: User.recordTypeKey, recordID: recordID)
        self.setValue(user.username, forKey: user.usernameKey)
        self.setValue(user.email, forKey: user.emailKey)
        self.setValue(user.appleUserRef, forKey: user.appleUserRefKey)
    }
}







