//
//  CloudKitSyncable.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/8/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable: class {
    
    var cloudKitRecordID: CKRecordID? { get set }
    var recordType: String { get }
}

extension CloudKitSyncable {
    
    var isSynced: Bool {
        return cloudKitRecordID != nil
    }
    
    var cloudKitReference: CKReference? {
        guard let recordID = cloudKitRecordID else { return nil }
        return CKReference(recordID: recordID, action: .deleteSelf)
    }
}
