//
//  FirstPageViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/28/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController, OnboardingScreen {
    
    var page: OnboardingState.Page = .title
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension FirstPageViewController: StoryboardInitializable {
    
    static var storyboardName: String { return String(describing: Onboarding.self) }
}
