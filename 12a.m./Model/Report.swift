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
    fileprivate let timestampKey = "timestamp"
    
    // MARK: - Properties
    
    let title: String
    var description: String?
    let reportReference: CKReference
    var ckRecordID: CKRecordID?
    var timestamp: String = Date().description(with: Locale.current)
    
    init(title: String, description: String? = String(), reportReference: CKReference, timestamp: String) {
        self.title = title
        self.description = description
        self.reportReference = reportReference
        self.timestamp = timestamp
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let title = cloudKitRecord[titleKey] as? String,
            let description = cloudKitRecord[descriptionKey] as? String?,
            let reportReference = cloudKitRecord[reportReferenceKey] as? CKReference,
            let timestamp = cloudKitRecord.creationDate?.description(with: .current) else { return nil }
        
        self.title = title
        self.description = description
        self.reportReference = reportReference
        self.ckRecordID = cloudKitRecord.recordID
        self.timestamp = timestamp
    }
}

extension CKRecord {
    convenience init(report: Report) {
        let recordID = report.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
    
        self.init(recordType: Report.reportRecordKey, recordID: recordID)
        
        self.setValue(report.title, forKey: report.titleKey)
        self.setValue(report.description, forKey: report.descriptionKey)
        self.setValue(report.reportReference, forKey: report.reportReferenceKey)
        self.setValue(report.timestamp, forKey: report.timestampKey)
    }
}





