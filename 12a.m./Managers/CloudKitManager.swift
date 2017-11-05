//
//  CloudKitManager.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/27/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import CloudKit
import UIKit

private let CreatorUserRecordIDKey = "creatorUserRecordID"
private let CreationDateKey = "creationDate"


class CloudKitManager {
    
    static let shared = CloudKitManager()
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    enum CloudKitTypes: String {
        case userType = "User"
    }
    
    
    // MARK: - Fetch Records
    
    // Give us everyting
    // To fetch information from cloudKit we run a Quiery. Can be: Give me all of the objects with this type or it can be very specific using predicates. Quiery Operations - lets us handel multiple objects.
    func fetchRecordsWithType(_ type: String,
                              predicate: NSPredicate = NSPredicate(value: true),
                              recordFetchedBlock: ((_ record: CKRecord) -> Void)?,
                              completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        let perRecordBlock = { (fetchedRecord: CKRecord) -> Void in
            fetchedRecords.append(fetchedRecord) // passes the record
            recordFetchedBlock?(fetchedRecord)
        }
        queryOperation.recordFetchedBlock = perRecordBlock
        
        var queryCompletionBlock: (CKQueryCursor?, Error?) -> Void = { (_, _) in }
        
        queryCompletionBlock = { [weak self] (queryCursor: CKQueryCursor?, error: Error?) -> Void in
            
            if let queryCursor = queryCursor {
                // there are more results, go fetch them
                
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = perRecordBlock
                continuedQueryOperation.queryCompletionBlock = queryCompletionBlock
                
                self?.publicDatabase.add(continuedQueryOperation)
                
            } else {
                completion?(fetchedRecords, error)
            }
        }
        queryOperation.queryCompletionBlock = queryCompletionBlock
        
        self.publicDatabase.add(queryOperation)
    } // Bring back all the records for the specified type
    
    // MARK: - User Info Discovery
    
    func fetchLoggedInUserRecord(_ completion: ((_ record: CKRecord?, _ error: Error? ) -> Void)?) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            
            if let error = error, let completion = completion {
                completion(nil, error)
            }
            
            if let recordID = recordID, let completion = completion {
                self.fetchRecord(withID: recordID, completion: completion)
            }
        }
    }
    
    func fetchRecord(withID recordID: CKRecordID, completion: ((_ record: CKRecord?, _ error: Error?) -> Void)?) {
        
        publicDatabase.fetch(withRecordID: recordID) { (record, error) in
            
            completion?(record, error)
        }
    } // Bring back the reocord for whatever item has that ID
    
    
    func fetchCurrentUserRecords(_ type: String, completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        fetchLoggedInUserRecord { (record, error) in
            
            if let record = record {
                
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [CreatorUserRecordIDKey, record.recordID])
                
                self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil, completion: completion)
            }
        }
    } // Retrieve the logged in user's record, and then all of the records that belong to that specific user --> Get Finn's record and then get all of the records associated with him (gun record, helmet record, etc.)
    
    func fetchRecordsFromDateRange(_ type: String, fromDate: Date, toDate: Date, completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        let startDatePredicate = NSPredicate(format: "%K > %@", argumentArray: [CreationDateKey, fromDate])
        let endDatePredicate = NSPredicate(format: "%K < %@", argumentArray: [CreationDateKey, toDate])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        
        self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            
            completion?(records, error)
        }
    } // Get all the records that were created between a start and end date (if you want the old stormtrooper helmet records, you might use this)
    
    // MARK: - Save and Modify
    
    func saveRecord(_ record: CKRecord, completion: ((_ record: CKRecord?, _ error: Error?) -> Void)?) {
        
        publicDatabase.save(record, completionHandler: { (record, error) in
            
            completion?(record, error)
        })
    }
    
    func modifyRecords(_ records: [CKRecord], perRecordCompletion: ((_ record: CKRecord?, _ error: Error?) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        
        operation.perRecordCompletionBlock = perRecordCompletion
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            if let error = error { print(error.localizedDescription) }
            (completion?(records, error))!
        }
        
        publicDatabase.add(operation)
    }
    
    
    
    // MARK: - Delete
    
    func deleteRecordWithID(_ recordID: CKRecordID, completion: ((_ recordID: CKRecordID?, _ error: Error?) -> Void)?) {
        
        publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
            completion?(recordID, error)
        }
    } // The record with the specified will be DESTROYED
    
    func deleteRecordsWithID(_ recordIDs: [CKRecordID], completion: ((_ records: [CKRecord]?, _ recordIDs: [CKRecordID]?, _ error: Error?) -> Void)?) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.savePolicy = .ifServerRecordUnchanged
        
        operation.modifyRecordsCompletionBlock = completion
        
        publicDatabase.add(operation)
    } // Find the younglings for these IDs, and kill their records
}
