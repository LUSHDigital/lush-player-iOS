//
//  LiveViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 30/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class LiveViewController: UIViewController, StateParentViewable {
    
    var liveViewState: LiveViewState = .loading(LoadingViewController()) {
        didSet {
            self.redraw()
        }
    }
    
    lazy var playerViewController: PlayerViewController = {
        
        let storyboard = UIStoryboard(name: "Live", bundle: nil)
        let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewControllerId") as? PlayerViewController
        
        return playerViewController ?? PlayerViewController()
    }()
    
    lazy var offAirViewController: OffAirViewController = {
       
        let storyboard = UIStoryboard(name: "Live", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OffAirViewControllerId") as? OffAirViewController
        
        return vc ?? OffAirViewController()
    }()
    
    func redraw() {
        
        switch liveViewState {
            
        case .loading(let loadingViewController):
            
            hideChildControllersIfNeeded()
            loadingViewController.view.frame = view.bounds
            loadingViewController.willMove(toParentViewController: self)
            addChildViewController(loadingViewController)
            self.view.addSubview(loadingViewController.view)
            loadingViewController.didMove(toParentViewController: self)
            
        case .live(let playerViewController):
            hideChildControllersIfNeeded()
            playerViewController.view.frame = view.bounds
            playerViewController.willMove(toParentViewController: self)
            addChildViewController(playerViewController)
            playerViewController.view.frame = playerViewContainer.bounds
            playerViewContainer.addSubview(playerViewController.view)
            
            playerViewController.didMove(toParentViewController: self)
            
        case .offAir(let offAirViewController):
            
            hideChildControllersIfNeeded()
            offAirViewController.view.frame = view.bounds
            addChildViewController(offAirViewController)
            self.view.addSubview(offAirViewController.view)
            offAirViewController.didMove(toParentViewController: self)
        }
    }
    
    
    @IBOutlet var playerViewContainer : UIView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        redraw()
//        self.liveViewState = .offAir(self.offAirViewCOntroller)
        refreshLive()

        // Do any additional setup after loading the view.
    }


    /// Refreshes live content from LUSH API
    private func refreshLive() {
        
        // Hit API
        LushPlayerController.shared.fetchLivePlaylist(with: nil, completion: { [weak self] (error, playlistID) in
            
            // Stop the loading indicator
            
            // If we have an error, handle it.
            if let error = error, let welf = self {
                
                if let lushError = error as? LushPlayerError {
                    switch lushError {
                    case .emptyResponse: // Handle empty response (No current live playlist)
        
                        if let welf = self {
                            welf.liveViewState = .offAir(welf.offAirViewController)
                            self?.redraw()
                        }
                        
                        return
                    case .invalidResponse, .invalidResponseStatus:
                        UIAlertController.presentError(error, in: welf)
                    }
                } else {
                    UIAlertController.presentError(error, in: welf)
                }
            }
            
            // Make sure we got a playlist ID back (should always be the case)
            guard let playlistID = playlistID else { return }
            
            // Set up the playback service
            self?.playerViewController.playbackService = BCOVPlaybackService(accountId: BrightcoveConstants.accountID, policyKey: BrightcoveConstants.livePolicyID)
            
            // Find the playlist using the ID provided by LUSH API
            self?.playerViewController.playbackService?.findPlaylist(withPlaylistID: playlistID, parameters: nil, completion: { [weak self] (playlist, jsonResponse, error) in
                
                // If we got an error, show it!
                if let error = error, let welf = self {
                    UIAlertController.presentError(error, in: welf)
                }
                
                // Setup the playlist, and redraw the view
                self?.playerViewController.playlist = playlist
                if let welf = self {
                    welf.playerViewController.playlist = playlist
                    welf.playerViewController.brightcovePolicyKey = BrightcoveConstants.livePolicyID
                    welf.liveViewState = .live(welf.playerViewController)
                }
                
            })
        })
    }
    
    
    

    
    enum LiveViewState {
        
        case loading(UIViewController)
        case live(PlayerViewController)
        case offAir(UIViewController)
    }
    
    
    
}
