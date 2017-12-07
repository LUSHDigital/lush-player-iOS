//
//  HomeCollectionViewController.swift
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
import LushPlayerKit

private let reuseIdentifier = "HomeCellId"

// View controller to display a overview feed of the newest programmes
class HomeCollectionViewController: ProgrammeListingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
    
        refresh()
    }
    
    // Reloads the programmes form the API and displays them
    func refresh() {
        
        viewState = .loading
        
        // There isn't currently a fetch all programmes end point so we need to request TV and Radio enpoints and merge the results
        
        // Fetch the latest TV programmes
        LushPlayerController.shared.fetchProgrammes(for: .TV, with: { [weak self] (error, programmes) in
            self?.handleResponse(error: error, programmes: programmes)
        })
        
        // Fetch the latest radio programmes
        LushPlayerController.shared.fetchProgrammes(for: .radio, with: { [weak self] (error, programmes) in
            self?.handleResponse(error: error, programmes: programmes)
        })
    }
    
    // Handles a response from either the TV or Radio enpoint
    func handleResponse(error: Error?, programmes: [Programme]?) {
        
        if let error = error {
            self.connectionErrorViewController.retryAction = { [weak self] in
                self?.refresh()
            }
            self.viewState = ContentListingViewState.error(error)
            return
        }
        
        if let programmes = programmes {
            self.viewState = .loaded(self.sortProgrammes(programmes))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    func sortProgrammes(_ programmes: [Programme]) -> [Programme] {
        // Sort the programmes by their date in chronological order
        let sortedProgrammes = LushPlayerController.shared.programmes.flatMap { (keyPair) in
            return keyPair.value
            }.sorted(by: { (p1, p2) -> Bool in
                
                guard let p1Date = p1.date, let p2Date = p2.date else {
                    return false
                }
                
                return p1Date > p2Date
            })
        
        return sortedProgrammes
    }
}
