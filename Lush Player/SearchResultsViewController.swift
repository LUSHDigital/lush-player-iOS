//
//  SearchViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class SearchResultsViewController: RefreshableViewController {
    
    var searchTerm: String?
    

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func refresh() {
        
        
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        searchTerm = searchController.searchBar.text
        refresh()
    }
}
