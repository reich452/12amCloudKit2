//
//  SubmitReportViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/5/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class SubmitReportViewController: UIViewController {
    
    // MARK: - Properties
    var report: Report?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        subMitReport()
    }
    
    func subMitReport() {
        guard let reportTitle = reportTitleLabel.text,
            let reportDetail = deatilTextView.text else { return }
        ReportController.shared.submitReport(with: reportTitle, and: reportDetail) { (report, error) in
            DispatchQueue.main.async { [weak self] in
                self?.deatilTextView.text = "You messesage was sent. We will process this information within 24 hours."
                self?.reportTitleLabel.text = "Thank You For Reporting"
            }
        }
    }
    
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var deatilTextView: UITextView!
    @IBOutlet weak var reportTitleLabel: UILabel!
    
}
