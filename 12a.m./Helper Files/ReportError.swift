//
//  ReportError.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/7/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import Foundation

enum ReportError: Error {
    case cannotConvertRecord
    case cannotSaveRecordToPublicDB
    case cannotFetchID
    case cannotFetchCKRecord
}
