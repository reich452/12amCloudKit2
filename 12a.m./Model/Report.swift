//
//  Report.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/3/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import Foundation

class Report {
    
    let title: String
    var description: String?
    
    init(title: String, description: String? = String()) {
        self.title = title
        self.description = description
    }
}
