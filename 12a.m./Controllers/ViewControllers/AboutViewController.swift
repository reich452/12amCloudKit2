//
//  AboutViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/27/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var wkWebView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTermsAndConditions()
    }
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
  private func setUpTermsAndConditions() {
        if let htmlFile = Bundle.main.path(forResource: "Terms", ofType: "html") {
                autoreleasepool(invoking: { [weak self] () -> Void in
                    if let htmlData = NSData(contentsOfFile: htmlFile) {
                    let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
                        self?.wkWebView.load(htmlData as Data, mimeType: "text/html", characterEncodingName: "UTF-8", baseURL: baseURL)
                }
            })
        }
    }
}


