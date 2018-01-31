//
//  SecondPageViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/30/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class SecondPageViewController: UIViewController, OnboardingScreen {
    @IBOutlet weak var pageControl: UIPageControl!
    
     var page: OnboardingState.Page = .uxInfo

    override func viewDidLoad() {
        super.viewDidLoad()
        setUPUI()
        print(pageControl.currentPage)
    }

    func setUPUI() {
        pageControl.currentPage = page.rawValue
    }


}

extension SecondPageViewController: StoryboardInitializable {
    
    static var storyboardName: String { return String(describing: Onboarding.self) }
}

