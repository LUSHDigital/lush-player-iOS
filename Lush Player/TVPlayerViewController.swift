//
//  TVPlayerViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 21/12/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class TVPlayerViewController: PlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If we have no programme then return
        guard let programme = programme else {
            return
        }
        
        self.play(programme: programme) { [weak self] (error) in
            var showGeoError: Bool = false
            
            // We need to check for a geoblocked error but its hella nested
            if let playbackErrors = (error as NSError).userInfo[kBCOVPlaybackServiceErrorKeyAPIErrors] as? [[AnyHashable: Any]] {
                showGeoError = playbackErrors.contains(where: { ($0["error_subcode"] as? String) == "CLIENT_GEO" })
            }
            
            let message = showGeoError ? "This video has not been made available in your area" : "This video is not currently available"
            
            let alertController = UIAlertController(title: "Video Unavailable", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] (action) in
                self?.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(okAction)
            
            DispatchQueue.main.async {
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        
        // Do any additional setup after loading the view.
    }

}
