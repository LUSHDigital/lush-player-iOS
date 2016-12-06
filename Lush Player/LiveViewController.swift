//
//  SecondViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    var playbackService: BCOVPlaybackService?
    
    var playlist: BCOVPlaylist?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        LushPlayerController.shared.fetchLivePlaylist(with: nil, completion: { [weak self] (error, playlistID) in
            
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            guard let playlistID = playlistID else { return }
            
            self?.playbackService = BCOVPlaybackService(accountId: BrightcoveConstants.accountID, policyKey: BrightcoveConstants.livePolicyID)
            
            self?.playbackService?.findPlaylist(withPlaylistID: playlistID, parameters: nil, completion: { [weak self] (playlist, jsonResponse, error) in
                
                if let error = error, let welf = self {
                    UIAlertController.presentError(error, in: welf)
                }
                
                self?.playlist = playlist
                self?.redraw()
            })
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func redraw() {
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let programme = sender as? Programme else { return }
        guard let playerVC = segue.destination as? PlayerViewController else { return }
        
        playerVC.brightcovePolicyKey = BrightcoveConstants.livePolicyID
        playerVC.programme = programme
    }
}

