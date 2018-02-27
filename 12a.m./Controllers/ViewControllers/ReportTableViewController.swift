//
//  ReportTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/3/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class ReportTableViewController: UITableViewController {
    
    var report: Report?
    var post: Post? 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReportController.shared.fetchReport { (reports, error) in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
   
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let reports = ReportController.shared.reports.prefix(9)
        
        return reports.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        let report = ReportController.shared.reports[indexPath.row]
        
        cell.textLabel?.text = report.title
        cell.detailTextLabel?.text = report.description
        
        return cell
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReportDetail" {
            guard let destinationVC = segue.destination as? ReportDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let report = ReportController.shared.reports[indexPath.row]
            destinationVC.report = report
        }
    }
}
