//
//  Comment.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/26/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import CloudKit

class Comment {

    static let recordTypeKey = "Comment"
    fileprivate let textKey = "text"
    fileprivate let timestampKey = "timestamp"
    fileprivate let postKey = "post"
    fileprivate let postReferenceKey = "postReference"
    fileprivate let ownerReferenceKey = "ownerReference"
    
    var text: String
    var timestamp: String
    var post: Post?
    var postReference: CKReference
    var owner: User?
    var ownerReference: CKReference
    var ckRecordID: CKRecordID?
    
    init(text: String, timestamp: String = Date().description(with: Locale.current), post: Post?, postReference: CKReference, ownerReference: CKReference) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.postReference = postReference
        self.ownerReference = ownerReference
    }
    
     init?(ckRecord: CKRecord) {
        guard let timestamp = ckRecord.creationDate?.description(with: .current),
            let text = ckRecord[textKey] as? String,
            let postReference = ckRecord[postReferenceKey] as? CKReference,
            let ownerReference = ckRecord[ownerReferenceKey] as? CKReference else { return nil }
        
        self.timestamp = timestamp
        self.text = text
        self.postReference = postReference
        self.ownerReference = ownerReference
        self.post = nil
        self.ckRecordID = ckRecord.recordID
    }
}

extension Comment: Equatable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        if lhs.text != rhs.text { return false }
        if lhs.timestamp != rhs.timestamp { return false }
        if lhs.post != rhs.post { return false }
        if lhs.postReference != rhs.postReference { return false }
        if lhs.owner != rhs.owner { return false }
        if lhs.ownerReference != rhs.ownerReference { return false }
        if lhs.ckRecordID != rhs.ownerReference { return false }
        return true
    }
    
}

extension CKRecord {
    
    convenience init(_ comment: Comment) {
        guard let post = comment.post else {
            fatalError("Comment does not have a Post relationship")
        }
        let recordID = comment.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Comment.recordTypeKey, recordID: recordID)
        self.setValue(comment.timestamp, forKey: comment.timestampKey)
        self.setValue(comment.text, forKey: comment.textKey)
        self.setValue(post.cloudKitReference, forKey: comment.postReferenceKey) // TODO - check Reference 
        self.setValue(comment.ownerReference, forKey: comment.ownerReferenceKey)
    }
}
