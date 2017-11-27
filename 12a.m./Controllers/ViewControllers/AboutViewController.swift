//
//  AboutViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/27/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTermsAndConditions()
    }
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpTermsAndConditions() {
        if let htmlFile = Bundle.main.path(forResource: "Terms", ofType: "html") {
            if let htmlData = NSData(contentsOfFile: htmlFile) {
                let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
                webView.load(htmlData as Data, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: baseURL)
            }
        }
    }
}


