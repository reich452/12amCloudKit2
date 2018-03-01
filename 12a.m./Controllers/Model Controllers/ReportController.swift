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
    
    typealias ReportCompletionHandeler = (Report?, ReportError?) -> Void
    typealias ReportsCompletionHandeler = ([Report]?, ReportError?) -> Void
    
    func submitReport(with title: String, and description: String?, timestamp: String = Date().description(with: .current), completion: @escaping ReportCompletionHandeler) {
        guard let userRecordID = UserController.shared.currentUser?.cloudKitRecordID else { return }
        
        let reference = CKReference(recordID: userRecordID, action: .none)
        
        let report = Report(title: title, description: description, reportReference: reference, timestamp: timestamp)
        
        reports.append(report)
        let reportRecord = CKRecord(report: report)
        
        cloudKitManager.saveRecord(reportRecord) { (ckRecord, error) in
            if let error = error {
                print("error saving record \(error) \(error.localizedDescription) \(#function)")
                completion(nil,.cannotSaveRecordToPublicDB); return
            }
            guard let _ = ckRecord else {
                completion(nil, .cannotConvertRecord); return
            }
            self.reports = [report]
            completion(report, nil)
        }
    }
    
    func fetchReport(completion: @escaping ReportsCompletionHandeler) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error { print("Error fetching userID: \(#function) \(error.localizedDescription) & \(error)")
                completion(nil, .cannotFetchID)
                return
            }
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "Report", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                self.cloudKitManager.publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (ckRecords, error) in
                    
                    if let error = error {
                        print("Error fetching reprot \(#function) \(error) \(error.localizedDescription)")
                        completion(nil, .cannotFetchCKRecord)
                    }
                    guard let ckRecords = ckRecords else {completion(nil, .cannotFetchCKRecord); return }
                    
                    let reports = ckRecords.flatMap{Report(cloudKitRecord: $0)}
                    
                    self.reports = reports
                    completion(reports, nil)
                    
                })
        }
    }
}
