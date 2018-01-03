/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

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

