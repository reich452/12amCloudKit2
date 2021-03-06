//
//  Onboarding.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/28/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

protocol OnboardingScreen where Self: UIViewController {
    
    var page: OnboardingState.Page { get }
    
}

class Onboarding: UIViewController {
    
    // MARK: - Properties
    
    var pageViewController: UIPageViewController!
    var currentPage = OnboardingState(currentPage: .welcome)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarView?.backgroundColor = .black 
        pageViewController.setViewControllers([FirstPageViewController.initializeFromStoryboard()], direction: .forward, animated: true, completion: nil)
        setUPUI()
    }
    func setUPUI() {
        UIApplication.shared.statusBarView?.backgroundColor = .black
        view.backgroundColor = .black
    }
    
}

// MARK: - Navigation

extension Onboarding {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .embedPageViewController:
            pageViewController = segue.destination as! UIPageViewController
            pageViewController.dataSource = self
            pageViewController.delegate = self
        }
    }
    
}

// MARK: - Page ViewController Datasource and Delegate

extension Onboarding: UIPageViewControllerDataSource {
    
    func createVCFrom(page: OnboardingState.Page) -> OnboardingScreen {
        switch page {
        case .welcome:
            let titlePage = FirstPageViewController.initializeFromStoryboard()
            return titlePage
        case .uxInfo:
            let uxInfoPage = SecondPageViewController.initializeFromStoryboard()
            return uxInfoPage
        case .selection:
            let selection = ThridPageViewController.initializeFromStoryboard()
            return selection
        case .permissions:
            let permissions = PermissionViewController.initializeFromStoryboard()
            return permissions
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let prevPage = currentPage.page
        let page = currentPage.previousPage()
        if prevPage == page { return nil }
        let vc = createVCFrom(page: page)
        return vc as? UIViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let prevPage = currentPage.page
        let page = currentPage.nextPage()
        if prevPage == page { return nil }
        let vc = createVCFrom(page: page)
        return vc as? UIViewController
    }
    
}

extension Onboarding: UIPageViewControllerDelegate {
    
}

// MARK: - Segue Handling

extension Onboarding: SegueHandling {
    
    enum SegueIdentifier: String {
        case embedPageViewController
    }
    
}

// MARK: - Storyboard Initializable

extension Onboarding: StoryboardInitializable { }

