//
//  AppDelegate.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var container: UIView!

    class func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // MARK: - Activity Indicator Functions

    func showActivityIndicator() {
        if let window = window {
            container = UIView()
            container.frame = window.frame
            container.center = window.center
            container.backgroundColor = UIColor(white: 0, alpha: 0.8)

            activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.center = CGPoint(x: container.frame.size.width/2,
                                               y: container.frame.size.height/2)

            container.addSubview(activityIndicator)
            window.addSubview(container)

            activityIndicator.startAnimating()
        }
    }

    func dismissActivityIndicator() {
        if let _ = window {
            activityIndicator.stopAnimating()
            container.removeFromSuperview()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        updateNavigationBarAppearance()
        return true
    }

    func updateNavigationBarAppearance() {
        // Updates the color of the navigation bar
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor(hexString: "0xffffff")
        navigationBarAppearance.barTintColor = UIColor(hexString: "0x707191")
        navigationBarAppearance.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationBarAppearance.isTranslucent = false

        // Updates the color of the status bar to white
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This
        // can occur for certain types of temporary interruptions (such as an incoming phone
        // call or SMS message) or when the user quits the application and it begins the
        // transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics
        // rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough application state information to restore your application to its
        // current state in case it is terminated later.
        // If your application supports background execution, this method is called
        // instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state;
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application
        // was inactive. If the application was previously in the background, optionally
        // refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        // See also applicationDidEnterBackground:.
    }

}

