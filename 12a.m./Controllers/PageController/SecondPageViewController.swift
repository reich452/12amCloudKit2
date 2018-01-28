//
//  SecondPageViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/28/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class SecondPageViewController: UIViewController, OnboardingScreen {
    @IBOutlet weak var pageControl: UIPageControl!
    
    var page: OnboardingState.Page = .genre1

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       pageControl.currentPage = page.rawValue
    }
}

private extension SecondPageViewController {
    
    func setupUI() {
        var genre = ""
        switch page {
        case .genre1: genre = "genre1"
        default: break
        }
         
        print("Selection Page: \(genre)")
    }
    
}

extension SecondPageViewController: StoryboardInitializable {
    
    static var storyboardName: String { return String(describing: Onboarding.self) }
}


