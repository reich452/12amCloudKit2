//
//  AppDelegate.swift
//  12a.m.
//
//  Created by Nick Reichard on 10/26/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private let feedId = "feedTVC"
    private let tabBarVC = "customTabBar"
    var timer: Timer!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(setUpTabBarController), userInfo: nil, repeats: false)
       
        UserController.shared.fetchCurrentUser()
        setUpTabBarController()
        
        return true
    }
    
    
   @objc func setUpTabBarController() {
    
        if UserController.shared.currentUser != nil {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let feedTVC = sb.instantiateViewController(withIdentifier: "customTabBar")
            self.window?.rootViewController = feedTVC
            self.window?.makeKeyAndVisible()
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = sb.instantiateViewController(withIdentifier: "signUpVC")
            self.window?.rootViewController = loginVC
            self.window?.makeKeyAndVisible()
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

