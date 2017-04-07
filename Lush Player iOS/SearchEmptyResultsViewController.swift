//
//  SearchEmptyResultsViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 06/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class SearchEmptyResultsViewController: UIViewController {

    @IBOutlet weak var contentStackView: UIStackView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var searchAgainButton: SpacedCharacterButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func pressedSearchAgain(_ sender: SpacedCharacterButton) {
        
        guard let parentVc = self.parent as? SearchResultsViewController, let searchVC = parentVc.parent as? SearchViewController else {
            return
        }
        
        searchVC.searchBar.becomeFirstResponder()
    }
}

