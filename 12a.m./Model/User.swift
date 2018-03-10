//
//  User.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/26/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation

class User {
    
    static let recordTypeKey = "User"
    fileprivate let usernameKey = "username"
    fileprivate let emailKey = "email"
    fileprivate let appleUserRefKey = "appleUserRef"
    fileprivate let imageKey = "photoData"
    fileprivate let blockUserRefKey = "blockUserRef"
    fileprivate let accessTokenKey = "acessToken"
    fileprivate let cityKey = "city"
    fileprivate let stateKey = "state"
    fileprivate let countryKey = "country"
    
    var username: String
    var email: String
    var profileImageData: Data?
    var cloudKitRecordID: CKRecordID?
    var blockUserRefs: [CKReference]? = []
    var blockUsersArray: [User] = []
    var posts: [Post]? = []
    var city: String? = nil
    var state: String? = nil
    var country: String? = nil
    let appleUserRef: CKReference
    
    @objc dynamic var isFollowing = false
    var hasCheckedFollowStatus = false
    
    
    var photo: UIImage? {
        guard let photoData = profileImageData else { return nil }
        return UIImage(data: photoData)
    }
    
    init(username: String, email: String, appleUserRef: CKReference, profileImageData: Data?, blockUserRefs: [CKReference]? = [], posts: [Post] = [], city: String = String(), state: String = String(), country: String = String()) {
        self.username = username
        self.email = email
        self.appleUserRef = appleUserRef
        self.profileImageData = profileImageData
        self.blockUserRefs = blockUserRefs
        self.posts = posts
        self.city = city
        self.state = state
        self.country = country
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let username = cloudKitRecord[usernameKey] as? String,
            let email = cloudKitRecord[emailKey] as? String,
            let appleUserRef = cloudKitRecord[appleUserRefKey] as? CKReference,
            let photoAsset = cloudKitRecord[imageKey] as? CKAsset,
            let profileImageData = try? Data(contentsOf: photoAsset.fileURL) else { return nil }
        
        self.blockUserRefs = cloudKitRecord[blockUserRefKey] as? [CKReference] ?? []
        self.city = cloudKitRecord[cityKey] as? String ?? nil
        self.state = cloudKitRecord[stateKey] as? String ?? nil
        self.country = cloudKitRecord[countryKey] as? String ?? nil
        
        self.username = username
        self.email = email
        self.appleUserRef = appleUserRef
        self.profileImageData = profileImageData
        self.cloudKitRecordID = cloudKitRecord.recordID
        self.posts = []
    }
    
    fileprivate var temporaryPhotoURL: URL {
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? profileImageData?.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
}

extension CKRecord {
    convenience init(user: User) {
        let recordID = user.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: User.recordTypeKey, recordID: recordID)
        self.setValue(user.username, forKey: user.usernameKey)
        self.setValue(user.email, forKey: user.emailKey)
        self.setValue(user.appleUserRef, forKey: user.appleUserRefKey)
        self.setValue(user.blockUserRefs, forKeyPath: user.blockUserRefKey)
        self[user.imageKey] = CKAsset(fileURL: user.temporaryPhotoURL)
        self.setValue(user.city, forKey: user.cityKey)
        self.setValue(user.state, forKey: user.stateKey)
        self.setValue(user.country, forKey: user.countryKey)
    }
}







