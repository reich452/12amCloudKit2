//
//  SubmitReportViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/5/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class SubmitReportViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    var report: Report?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        deatilTextView.delegate = self 
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
    
    func updateViews() {
        guard let report = report else { return }
        reportTitleLabel.text = report.title
        deatilTextView.layer.cornerRadius = 10
        
        deatilTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (deatilTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        deatilTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (deatilTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !deatilTextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    
    var placeholderLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var deatilTextView: UITextView!
    @IBOutlet weak var reportTitleLabel: UILabel!
    
}
