//
//  Theme.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/4/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var primaryAppBlue: UIColor {
        return UIColor(red: 5.0 / 255.0, green: 135.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    static var backgroundAPpGrey: UIColor {
        return UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
    }
    
    static var highlightGreen: UIColor {
        return UIColor(red: 84.0 / 255.0, green: 252.0 / 255.0, blue: 72.0 / 255.0 , alpha: 1.0)
    }
    
    static var navBarTint: UIColor {
        return UIColor(red: 25.0/255.0, green: 31.0/255.0, blue: 41.0/255.0, alpha: 0.0001)
    }
    
    static var digitalGreen: UIColor {
        return UIColor(red: 3.0/255.0, green: 220.0/255.0, blue: 191.0/255.0, alpha: 1.0)
    }
    static var cellBackgroundBlue: UIColor {
        return UIColor(red: 15.0/255.0, green: 29.0/255.0, blue: 32.0/255.0, alpha: 1.0)
    }
    
    static var cellBackgroundBlue2: UIColor {
        return UIColor(red: 32.0/255.0, green: 42.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    }
    
    static var refreshControllGreen: UIColor {
        return UIColor(red: 0.0/255.0, green: 219.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    }
    
    static var digitalBlue: UIColor {
        return UIColor(red: 101.0/255.0, green: 210.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}




