//
//  ReportTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/3/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class ReportTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ReportController.shared.mockReports.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        let report = ReportController.shared.mockReports[indexPath.row]
        
        cell.textLabel?.text = report.title
        cell.detailTextLabel?.text = report.description
        
        return cell
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReportDetail" {
            guard let destinationVC = segue.destination as? ReportDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let report = ReportController.shared.mockReports[indexPath.row]
            destinationVC.report = report
        }
    }
}
