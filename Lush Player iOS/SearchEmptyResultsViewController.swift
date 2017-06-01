//
//  SearchEmptyResultsViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 06/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Displayed when search results return nothing
class SearchEmptyResultsViewController: UIViewController {

    // Containing stack view
    @IBOutlet weak var contentStackView: UIStackView!
    
    // Label to show a small description
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Button for searching again
    @IBOutlet weak var searchAgainButton: SpacedCharacterButton!
    
    // Button action - simply makes the search bar first responder 
    @IBAction func pressedSearchAgain(_ sender: SpacedCharacterButton) {
        
        guard let parentVc = self.parent as? SearchResultsViewController, let searchVC = parentVc.parent as? SearchViewController else {
            return
        }
        
        searchVC.searchBar.becomeFirstResponder()
    }
}

