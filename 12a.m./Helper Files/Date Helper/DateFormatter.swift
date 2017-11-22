//
//  DateFormatter.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/13/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
extension Date {
    
    var formatter: DateFormatter? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }
    
    var timePosted: DateFormatter? {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
