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
    fileprivate let ownerReferenceKey = "ownerRefKey"
    fileprivate let reportReferenceKey = "reportReference"
    
    // MARK: - Properties
    
    let title: String
    let ownerReference: CKReference
    var description: String?
    var owner: User?
    var ckRecordID: CKRecordID?
  
    
    init(title: String, description: String? = String(), ownerReference: CKReference, owner: User) {
        self.title = title
        self.description = description
        self.ownerReference = ownerReference
        self.owner = owner
       
    }
    
    init?(ckRecord: CKRecord) {
        guard let title = ckRecord[titleKey] as? String,
            let ownerReference = ckRecord[ownerReferenceKey] as? CKReference,
            let description = ckRecord[descriptionKey] as? String else { return nil }
        
        self.title = title
        self.ownerReference = ownerReference
        self.description = description
        self.ckRecordID = ckRecord.recordID

    }
}

extension CKRecord {
    
    convenience init(report: Report) {
         let recordID = report.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: Report.recordTypeKey, recordID: recordID)
        self.setValue(report.title, forKeyPath: report.titleKey)
        self.setValue(report.ownerReference, forKeyPath: report.ownerReferenceKey)
        self.setValue(report.description, forKeyPath: report.descriptionKey)
     
    }
}





