//
//  AppDelegate.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch let error as NSError {
            print(error)
        }
        
        setupSearchTab()
        
        return true
    }

    func setupSearchTab() {
        
        guard let tabController = window?.rootViewController as? UITabBarController, var tabViewControllers = tabController.viewControllers else { return }
        guard let resultsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResults") as? SearchResultsViewController else { return }
        
        let searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.searchBarStyle = .minimal
        
        let searchContainerViewController = UISearchContainerViewController(searchController: searchController)
        
        let searchNavController = UINavigationController(rootViewController: searchContainerViewController)
        searchNavController.tabBarItem.title = "Search"
        
        tabViewControllers.append(searchNavController)
        tabController.viewControllers = tabViewControllers
        
        window?.rootViewController = tabController
    }
}

