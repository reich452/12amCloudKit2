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
    
    typealias ReportCompletionHandeler = (Report?, ReportError?) -> Void
    
    func submitReport(with title: String, and description: String?, completion: @escaping ReportCompletionHandeler) {
       
        guard let postReference = PostController.shared.post?.cloudKitReference,
            let userReference = UserController.shared.currentUser?.appleUserRef else { return }
        let reportReference = CKReference(recordID: postReference.recordID, action: .none)
        
        let report = Report(title: title, description: description, postReference: postReference, reportReference: reportReference, userReference: userReference)
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
 
    
}
