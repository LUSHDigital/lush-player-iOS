//
//  AppDelegate.swift
//  Lush Player iOS
//
//  Created by Joel Trew on 20/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import AVFoundation
import Fabric
import Crashlytics

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var statusBarBackground = UIView(frame: UIApplication.shared.statusBarFrame)


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Set the correct background audio category for correct background behaviour
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print(error)
        }
        
        // Setup screen rotation observer
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Overall App customisation 
        customiseApp()
        
        // Google Analytics
        let googleAnalyticsCode = Bundle.main.object(forInfoDictionaryKey: "TSCGoogleTrackingId")
        
        if let _gaCode = googleAnalyticsCode as? String {
            let gai = GAI()
            gai.tracker(withTrackingId: _gaCode)
            gai.dispatchInterval = 60
        }
        
        // Initialise Crashlytics
        Fabric.with([Crashlytics.self])
        
        GATracker.trackPage(named: "Start")
        
        return true
    }
    
    func rotated() {
        statusBarBackground.isHidden = UIApplication.shared.isStatusBarHidden
    }
    
    func customiseApp() {
        
        let navbar = UINavigationBar.appearance()
        navbar.isTranslucent = false
        navbar.barTintColor = UIColor.black
        navbar.tintColor = UIColor.white
        navbar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        let tabbar = UITabBar.appearance()
        tabbar.isTranslucent = false
        tabbar.barTintColor = UIColor.white
        tabbar.tintColor = UIColor.black
        
        statusBarBackground.backgroundColor = UIColor(colorLiteralRed: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        
        self.window?.rootViewController?.view.addSubview(statusBarBackground)
        
        statusBarBackground.translatesAutoresizingMaskIntoConstraints = false
        statusBarBackground.superview?.addConstraint(NSLayoutConstraint(item: statusBarBackground, attribute: .top, relatedBy: .equal, toItem: statusBarBackground.superview, attribute: .top, multiplier: 1.0, constant: 0.0))
        statusBarBackground.superview?.addConstraint(NSLayoutConstraint(item: statusBarBackground, attribute: .left, relatedBy: .equal, toItem: statusBarBackground.superview, attribute: .left, multiplier: 1.0, constant: 0.0))
        statusBarBackground.superview?.addConstraint(NSLayoutConstraint(item: statusBarBackground, attribute: .right, relatedBy: .equal, toItem: statusBarBackground.superview, attribute: .right, multiplier: 1.0, constant: 0.0))
        statusBarBackground.addConstraint(NSLayoutConstraint(item: statusBarBackground, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIApplication.shared.statusBarFrame.height))

        statusBarBackground.superview?.setNeedsUpdateConstraints()
        statusBarBackground.isHidden = UIApplication.shared.isStatusBarHidden
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
