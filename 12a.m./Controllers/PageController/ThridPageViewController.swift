//
//  ThridPageViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/30/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class ThridPageViewController: UIViewController, OnboardingScreen {
    @IBOutlet weak var pageControl: UIPageControl!
    
    var page: OnboardingState.Page = .selection
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUPUI()
        print(pageControl.currentPage)
    }
    
    func setUPUI() {
        pageControl.currentPage = page.rawValue
    }

}

extension ThridPageViewController: StoryboardInitializable {
    
    static var storyboardName: String { return String(describing: Onboarding.self) }
}



