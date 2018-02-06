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
    static let recordTypeKey = "Report"
    fileprivate let titleKey = "title"
    fileprivate let descriptionKey = "description"
    fileprivate let ownerReferenceKey = "ownerReference"
    fileprivate let reportReferenceKey = "reportReference"
    fileprivate let postReferenceKey = "postReference"
    
    // MARK: - Properties
    
    let title: String
    let ownerReference: CKReference
    var description: String?
    var owner: User?
    var ckRecordID: CKRecordID?
    var postReference: CKReference
  
    
    init(title: String, description: String? = String(), ownerReference: CKReference, owner: User?, postReference: CKReference) {
        self.title = title
        self.description = description
        self.ownerReference = ownerReference
        self.owner = owner
        self.postReference = postReference
       
    }
    
    init?(ckRecord: CKRecord) {
        guard let title = ckRecord[titleKey] as? String,
            let ownerReference = ckRecord[ownerReferenceKey] as? CKReference,
            let description = ckRecord[descriptionKey] as? String,
            let postReference = ckRecord[postReferenceKey] as? CKReference else { return nil }
        
        self.title = title
        self.ownerReference = ownerReference
        self.description = description
        self.postReference = postReference
        self.ckRecordID = ckRecord.recordID

    }
}

extension CKRecord {
    
    convenience init(report: Report) {
         let recordID = report.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        guard let user = report.owner else {
            fatalError("report doesn't have a owner")
        }
        
        self.init(recordType: Report.recordTypeKey, recordID: recordID)
        self.setValue(report.title, forKeyPath: report.titleKey)
        self.setValue(report.description, forKeyPath: report.descriptionKey)
        self.setValue(user.appleUserRef, forKey: report.ownerReferenceKey)
        self.setValue(report.ownerReference, forKey: report.reportReferenceKey)
        self.setValue(report.postReference, forKey: report.postReferenceKey)
    
    }
}





