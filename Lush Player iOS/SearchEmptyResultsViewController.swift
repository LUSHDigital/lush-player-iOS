//
//  SearchEmptyResultsViewController.swift
//  Lush Player
//
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

