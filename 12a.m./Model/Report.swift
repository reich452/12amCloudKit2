//
//  Report.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/3/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import Foundation
import CloudKit

class Report {
    
    // MARK: - Keys
    
    static let reportRecordKey = "Report"
    fileprivate let titleKey = "title"
    fileprivate let descriptionKey = "description"
    fileprivate let postReferenceKey = "postReference"
    fileprivate let reportReferenceKey = "reportReference"
    fileprivate let userReferenceKey = "userReference"
    
    // MARK: - Properties
    
    let title: String
    var description: String?
    let postReference: CKReference
    let reportReference: CKReference
    let userReference: CKReference
    var user: User?
    var post: Post?
    var ckRecordID: CKRecordID?
    
    init(title: String, description: String? = String(), postReference: CKReference, reportReference: CKReference, userReference: CKReference) {
        self.title = title
        self.description = description
        self.postReference = postReference
        self.reportReference = reportReference
        self.userReference = userReference
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let title = cloudKitRecord[titleKey] as? String,
            let description = cloudKitRecord[descriptionKey] as? String,
            let postReference = cloudKitRecord[postReferenceKey] as? CKReference,
            let reportReference = cloudKitRecord[reportReferenceKey] as? CKReference,
            let userReference = cloudKitRecord[userReferenceKey] as? CKReference else { return nil }
        
        self.title = title
        self.description = description
        self.postReference = postReference
        self.reportReference = reportReference
        self.userReference = userReference
        self.ckRecordID = cloudKitRecord.recordID
    }
}

extension CKRecord {
    convenience init(report: Report) {
        let recordID = report.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        guard let user = report.post?.owner,
            let postReference = report.post else {
            fatalError("No user to post relationship")
        }
        self.init(recordType: Report.reportRecordKey, recordID: recordID)
        
        self.setValue(report.title, forKey: report.titleKey)
        self.setValue(report.description, forKey: report.descriptionKey)
        self.setValue(report.reportReference, forKey: report.reportReferenceKey)
        self.setValue(postReference.cloudKitReference, forKey: report.postReferenceKey)
        self.setValue(user.appleUserRef, forKey: report.userReferenceKey)
    }
}





