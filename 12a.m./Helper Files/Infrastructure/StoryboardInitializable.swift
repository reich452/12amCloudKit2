//
//  StoryboardInitializable.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/28/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

public protocol StoryboardInitializable {
    static var storyboardName: String { get }
    static var viewControllerIdentifier: String { get }
}

public extension StoryboardInitializable where Self: UIViewController {
    
    public static var storyboardName: String {
        return String(describing: Self.self)
    }
    
    public static var viewControllerIdentifier: String {
        return String(describing: Self.self)
    }
    
    public static func initializeFromStoryboard() -> Self {
        let bundle = Bundle(for: Self.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? Self else { fatalError("Error instantiating \(self) from storyboard") }
        return vc
    }
    
}
