//
//  HomeCollectionViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

private let reuseIdentifier = "HomeCellId"

class HomeCollectionViewController: ProgrammeListingViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
    
        refresh()
    }
    
    func refresh() {
        
        viewState = .loading
        
        // Fetch the latest TV programmes
        LushPlayerController.shared.fetchProgrammes(for: .TV, with: { [weak self] (error, programmes) in
            self?.handleResponse(error: error, programmes: programmes)
        })
        
        // Fetch the latest radio programmes
        LushPlayerController.shared.fetchProgrammes(for: .radio, with: { [weak self] (error, programmes) in
            self?.handleResponse(error: error, programmes: programmes)
        })
    }
    
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
