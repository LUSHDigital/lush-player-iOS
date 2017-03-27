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

class HomeCollectionViewController: ContentListingViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        // Fetch the latest TV programmes
        LushPlayerController.shared.fetchProgrammes(for: .TV, with: { [weak self] (error, programmes) in
            if let welf = self {
                
                if let error = error {
                    welf.viewState = ContentListingViewState.error(welf.errorStateViewController)
                    return
                }
            
                if let programmes = programmes {
                    welf.viewState = .loaded(welf.sortProgrammes(programmes))
                }
            }
        })
        
        // Fetch the latest radio programmes
        LushPlayerController.shared.fetchProgrammes(for: .radio, with: { [weak self] (error, programmes) in
            
            if let welf = self {
                
                if let error = error {
                    welf.viewState = ContentListingViewState.error(welf.errorStateViewController)
                    return
                }
                
                if let programmes = programmes {
                    
                    welf.viewState = .loaded(welf.sortProgrammes(programmes))
                    return
                }
            }
        })
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "MediaDetailSegue" {
            if let destination = segue.destination as? MediaDetailViewController, let programme = sender as? Programme {
                
                destination.programme = programme
            }
        }
    }
    
    override func showProgramme(programme: Programme) {
        super.showProgramme(programme: programme)
        self.performSegue(withIdentifier: "MediaDetailSegue", sender: programme)
    }
}
