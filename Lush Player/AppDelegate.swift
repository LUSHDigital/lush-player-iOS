//
//  AppDelegate.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set the correct background audio category for correct background behaviour
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print(error)
        }
        
        setupSearchTab()
        
        return true
    }

    
    /// Sets up the search tab as a UISearchController, this is done manually as IB has no support for this
    func setupSearchTab() {
        
        // Get the root UITabBarController
        guard let tabController = window?.rootViewController as? UITabBarController, var tabViewControllers = tabController.viewControllers else { return }
        
        // Allocate search results VC from Main.storyboard
        guard let resultsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResults") as? SearchResultsViewController else { return }
        
        // Set up our UISearchController
        let searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.searchBarStyle = .minimal
        
        let searchContainerViewController = UISearchContainerViewController(searchController: searchController)
        
        let searchNavController = UINavigationController(rootViewController: searchContainerViewController)
        searchNavController.tabBarItem.title = "Search"
        
        // Add the tab into our UITabBarController
        tabViewControllers.append(searchNavController)
        tabController.viewControllers = tabViewControllers
        
        // Reset the rootViewController on our window
        window?.rootViewController = tabController
    }
}

