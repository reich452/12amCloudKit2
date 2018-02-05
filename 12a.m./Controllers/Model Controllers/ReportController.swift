//
//  ReportController.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/3/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import Foundation
import CloudKit

class ReportController {
    static let shared = ReportController()
    
    let cloudKitManager = CloudKitManager()
    
    var reports: [Report] = []
    var report: Report?
    
    func createReport(title: String, description: String?, completion: @escaping () -> Void) {
        guard let report = report,
            let owner = report.owner,
            let cloudKitRecordID = owner.cloudKitRecordID else { return }
        let ownerReference = CKReference(recordID: cloudKitRecordID, action: .deleteSelf)
        
        let usersReport = Report(title: title, description: description, ownerReference: ownerReference, owner: owner)
        reports.append(usersReport)
        let reportRecord = CKRecord(report: usersReport)
        
        cloudKitManager.saveRecord(reportRecord) { (ckRecord, error) in
            
            if let error = error {
                print("Error saveing record \(error) \(error)")
                completion(); return
            }
            self.reports = [report]
            completion()
           
        }
    }
    
    func fetchReportedUsers(completion: @escaping ([Report]?) -> Void) {
        
        cloudKitManager.fetchAllRecordsWithType(Report.recordTypeKey) { (records, error) in
            
            if let error = error {
                print("Error fetching \(error) \(error.localizedDescription)")
                completion(nil); return
            }
            guard let records = records else { completion(nil); return }
            let reports = records.flatMap{Report(ckRecord: $0)}
            self.reports = reports
            completion(reports)
            
        }
    }

    
}
