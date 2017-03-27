//
//  ChannelListingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 27/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class ChannelListingViewController: ContentListingViewController {
    
    var selectedChannel: Channel?

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        // Do any additional setup after loading the view.
    }
    
    func refresh() {
        guard let selectedChannel = selectedChannel else { return }
        // If we've already pulled the programmes for the selected channel
        if let programmes = LushPlayerController.shared.channelProgrammes[selectedChannel] {
            if programmes.isEmpty {
                self.viewState = .empty(emptyStateViewController)
                return
            }
            self.viewState  = .loaded(programmes)
            
        } else {
            
            // Fetch the programmes for a specified channel
            LushPlayerController.shared.fetchProgrammes(for: selectedChannel, of: nil, with: { [weak self] (error, programmes) -> (Void) in
                
                // If we get an error, then display it
                if let error = error, let welf = self {
                    welf.viewState = .error(welf.errorStateViewController)
                    UIAlertController.presentError(error, in: welf)
                }
                

                if let programmes = programmes {
                    // If there are no programmes so the empty state
                    if programmes.isEmpty, let emptyStateViewController = self?.emptyStateViewController {
                        self?.viewState = .empty(emptyStateViewController)
                        return
                    }
                    
                    self?.viewState  = .loaded(programmes)
                    return
                }
                
            })
        }
    }
    
    
    override func showProgramme(programme: Programme) {
        super.showProgramme(programme: programme)
        
        self.performSegue(withIdentifier: "MediaDetailSegue", sender: programme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "MediaDetailSegue" {
            if let destination = segue.destination as? MediaDetailViewController, let programme = sender as? Programme {
                
                destination.programme = programme
            }
        }
    }
    
}



enum ChannelError: Error, LocalizedError {
    
    case noProgrammes
}
