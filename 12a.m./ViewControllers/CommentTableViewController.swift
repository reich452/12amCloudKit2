//
//  CommentTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/6/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class CommentTableViewController: UITableViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Properties
    
    var post: Post? 
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
