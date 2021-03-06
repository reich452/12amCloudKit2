//
//  Post.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/26/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import CloudKit
import UIKit

class Post {

    
    
    static let recordTypeKey = "Post"
    fileprivate let photoDataKey = "photoData"
    fileprivate let timestampKey = "timestamp"
    fileprivate let textKey = "text"
    fileprivate let ownerKey = "owner"
    fileprivate let ownerReferenceKey = "ownerRef"
    
    let photoData: Data?
    let timestamp: Date
    let text: String
    var comments: [Comment]
    weak var owner: User?
    var ownerReference: CKReference
    var ckRecordID: CKRecordID?
    
    var recordType: String {
        return Post.recordTypeKey
    }
    
    var cloudKitReference: CKReference? {
        guard let cloudKitRecordID = self.ckRecordID else { return nil }
        return CKReference(recordID: cloudKitRecordID, action: .deleteSelf)
    }
    
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    init(photoData: Data?, timestamp: Date = Date(), text: String, comments: [Comment] = [], owner: User, ownerReference: CKReference) {
        self.photoData = photoData
        self.timestamp = timestamp
        self.text = text
        self.comments = comments.sorted(by: {$0.timestamp > $1.timestamp })
        self.owner = owner
        self.ownerReference = ownerReference
    }
    
    init?(ckRecord: CKRecord) {
        guard let timestamp = ckRecord[timestampKey] as? Date,
            let text = ckRecord[textKey] as? String,
            let photoAsset = ckRecord[photoDataKey] as? CKAsset,
            let photoData = try? Data(contentsOf: photoAsset.fileURL),
            let ownerReference = ckRecord[ownerReferenceKey] as? CKReference else { return nil }
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.text = text
        self.ownerReference = ownerReference
        self.ckRecordID = ckRecord.recordID
        self.comments = []
    }
    
     var temporaryPhotoURL: URL {
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirecoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirecoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? photoData?.write(to: fileURL, options: [.atomic])
        if photoData == nil {
            print("Error with post photo data ")
        }
        return fileURL
    }
}

extension Post: Equatable {
    static func ==(lhs: Post, rhs: Post) -> Bool {
        if lhs.photoData != rhs.photoData { return false }
        if lhs.timestamp != rhs.timestamp { return false }
        if lhs.text != rhs.text { return false }
        if lhs.comments != rhs.comments { return false }
        if lhs.owner != rhs.owner { return false }
        if lhs.ownerReference != rhs.ownerReference { return false }
        if lhs.ckRecordID != rhs.ckRecordID { return false }
        return true
    }
}

extension CKRecord {
    
    convenience init(_ post: Post) {
        let recordID = post.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: post.recordType, recordID: recordID)
        self[post.textKey] = post.text as CKRecordValue
        self[post.timestampKey] = post.timestamp as NSDate
        self[post.photoDataKey] = CKAsset(fileURL: post.temporaryPhotoURL)
        guard let owner = post.owner,
            let ownerRecordID = owner.cloudKitRecordID
            else { return }
        self[post.ownerReferenceKey] = CKReference(recordID: ownerRecordID, action: .deleteSelf)
    }
}





