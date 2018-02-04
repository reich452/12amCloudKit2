//
//  ReportController.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/3/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import Foundation

class ReportController {
    static let shared = ReportController()
    
    var mockReports: [Report] {
        return [Report(title: "Self injury", description: "Eating disorders, cutting or promoting suiside"),
                Report(title: "Harassment or bullying"),
                Report(title: "Sale or promotion of drugs"),
                Report(title: "Sale or promotion of firearms"),
                Report(title: "Nudity or pornography"),
                Report(title: "Violence or harm", description: "Graphic injury, unlawful activity, dangerous or criminal organizations"),
                Report(title: "Hate speech or symbols", description: "Racist, homophobic or sexist slurs"),
                Report(title: "Intellectual property violation", description: "Copyright or tradmark infringement"),
                Report(title: "I just dont like it")]
    }
    
}
