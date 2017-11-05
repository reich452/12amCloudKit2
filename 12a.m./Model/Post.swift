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
    
    fileprivate let typeKey = "Post"
    fileprivate let photoDataKey = "photoData"
    fileprivate let timestampKey = "timestamp"
    fileprivate let textKey = "text"
    fileprivate let ownerKey = "owner"
    fileprivate let ownerReferenceKey = "ownerRef"
    
    let photoData: Data?
    let timestamp: Date
    let text: String
    var comments: [Comment]
    var owner: User?
    var ownerReference: CKReference
    var ckRecordID: CKRecordID?
    
    var cloudKitReference: CKReference? {
        guard let cloudKitRecordID = self.ckRecordID else { return nil }
        return CKReference(recordID: cloudKitRecordID, action: .none)
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
    
    fileprivate var temporaryPhotoURL: URL {
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirecoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirecoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? photoData?.write(to: fileURL, options: .atomic)
        if photoData == nil {
            print("Error with post photo data ")
        }
        return fileURL
    }
}

extension CKRecord {
    
    convenience init(_ post: Post) {
        let recordID = post.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: post.typeKey, recordID: recordID)
        self.setValue(post.text, forKeyPath: post.textKey)
        self.setValue(post.timestamp, forKeyPath: post.timestampKey)
        self[post.photoDataKey] = CKAsset(fileURL: post.temporaryPhotoURL)
        guard let owner = post.owner,
            let ownerRecordID = owner.cloudKitRecordID else { return }
        self[post.ownerReferenceKey] = CKReference(recordID: ownerRecordID, action: .deleteSelf)
    }
}





