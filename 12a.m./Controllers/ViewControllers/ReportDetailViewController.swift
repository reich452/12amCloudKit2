//
//  ReportDetailViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/3/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class ReportDetailViewController: UIViewController {

    @IBOutlet weak var reportTitle: UILabel!
    
    // MARK: - Properties 
    
    var report: Report?
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        print(post?.cloudKitReference)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func updateViews() {
        guard let report = report else { return }
        reportTitle.text = report.title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSubmitReport" {
            guard let destinationVC = segue.destination as? SubmitReportViewController else { return }
           
        }
    }

}