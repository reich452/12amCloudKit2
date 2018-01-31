//
//  FirstPageViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/28/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController, OnboardingScreen {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var page: OnboardingState.Page = .welcome
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUPUI()
    }
    
    func setUPUI() {
        pageControl.currentPage = page.rawValue
        UIApplication.shared.statusBarStyle = .default
        print(pageControl.numberOfPages)
        print(pageControl.currentPage)
    }

}

extension FirstPageViewController: StoryboardInitializable {
    
    static var storyboardName: String { return String(describing: Onboarding.self) }
}
