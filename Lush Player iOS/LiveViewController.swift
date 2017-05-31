//
//  LiveViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 30/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

// View controller for viewing live streams from LUSH player API
class LiveViewController: UIViewController, StateParentViewable {
    
    // The current state of the view controller, i.e loading, live, off-air
    var liveViewState: LiveViewState = .loading(LoadingViewController()) {
        didSet {
            self.redraw()
        }
    }
    // View controller for when there is a live stream
    lazy var playerViewController: PlayerViewController = {
        
        let storyboard = UIStoryboard(name: "Live", bundle: nil)
        let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewControllerId") as? PlayerViewController
        
        return playerViewController ?? PlayerViewController()
    }()
    
    // View controller for when there is no live stream avialible to watch
    lazy var offAirViewController: OffAirViewController = {
       
        let storyboard = UIStoryboard(name: "Live", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OffAirViewControllerId") as? OffAirViewController
        
        return vc ?? OffAirViewController()
    }()
    
    // The conatiner view for the player
    @IBOutlet weak var playerViewContainer : UIView!
    
    // Label to show: the title of the content
    @IBOutlet weak var titleLabel: UILabel!
    
    // Label to show: a small description of the content thats playing
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Label to show: the amount of time remaining on the live stream
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    // Label to show: The time the live stream dated
    @IBOutlet weak var dateLabel: UILabel!
    
    // Switch between view controllers depending on the state of the view controller, i.e only show the off-air view controller if that is our current view state
    func redraw() {
        
        switch liveViewState {
            
        case .loading(let loadingViewController):
            
            hideChildControllersIfNeeded()
            loadingViewController.view.frame = view.bounds
            loadingViewController.willMove(toParentViewController: self)
            addChildViewController(loadingViewController)
            self.view.addSubview(loadingViewController.view)
            loadingViewController.didMove(toParentViewController: self)
            
        case .live(let playlist):
            hideChildControllersIfNeeded()
            playerViewController.playlist = playlist
            self.play(playlist: playlist)
            playerViewController.play(playlist: playlist)
            
        case .offAir(let offAirViewController):
            
            hideChildControllersIfNeeded()
            offAirViewController.view.frame = view.bounds
            addChildViewController(offAirViewController)
            self.view.addSubview(offAirViewController.view)
            offAirViewController.didMove(toParentViewController: self)
        }
    }
    
    
    func hideChildControllersIfNeeded() {
        for vc in self.childViewControllers {
            
            if vc is OffAirViewController || vc is LoadingViewController {
                vc.willMove(toParentViewController: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }
            
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerViewController.brightcovePolicyKey = BrightcoveConstants.livePolicyID
        playerViewController.view.frame = view.bounds
        playerViewController.willMove(toParentViewController: self)
        addChildViewController(playerViewController)
        playerViewController.view.frame = playerViewContainer.bounds
        playerViewContainer.addSubview(playerViewController.view)
        
        playerViewController.didMove(toParentViewController: self)
        
        
        redraw()
        refreshLive()
    }
    
    // Check for new live stream every time we show the view controller
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshLive()
    }
    
    @IBAction func pressedShare(sender: Any) {
        print("Share")
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
                    return
                }
                
                // Setup the playlist, and redraw the view
                if let playlist = playlist {
                    self?.liveViewState = .live(playlist)
                    return
                }
            })
        })
    }
    
    // Commented out until futher notice
    func play(playlist: BCOVPlaylist) {
        
//        // Invalidate redraw timer
//        redrawTimer?.invalidate()
//
//        // Make sure we have a position within it to play from
        guard let playlistPosition = playlist.playlistPosition else {
//
//            // Check every 60 seconds for live playlist content!
//            redrawTimer = Timer(fire: Date(timeIntervalSinceNow: 60), interval: 0, repeats: false, block: { [weak self] (timer) in
//                self?.refreshLive()
//            })
//
            return
        }
        
        
        self.playerViewController.play(playlist: playlist)
//
//        // We got a playlist, so stop playing fallback video
//
//        // Fire a timer 1 second after programme is scheduled to end, to redraw!
//        remainingTimer?.invalidate()
//        redrawTimer = Timer(fire: playlistPosition.scheduleItem.endDate.addingTimeInterval(1), interval: 0, repeats: false, block: { [weak self] (timer) in
//            self?.redraw()
//        })
//
//        // Show all UI in a nice animated fashion
        
        // date formatter for date label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mma"
        descriptionLabel.text = nil
        
        // Update remaining time label
//        redrawRemainingLabel(playlistPosition: playlistPosition)
        
        // Update date label
        dateLabel.text = "\(dateFormatter.string(from: playlistPosition.scheduleItem.startDate)) - \(dateFormatter.string(from: playlistPosition.scheduleItem.endDate))"
        
        // Set title label to name of video
        let video = playlistPosition.scheduleItem.video
        titleLabel.text = video.properties["name"] as? String
        
        // If we have a poster url on the video object, display it in background
//        if let posterString = video.properties["poster"] as? String, let posterURL = URL(string: posterString) {
//            imageView.set(imageURL: posterURL, withPlaceholder: nil, completion: nil)
//        } else {
//            imageView.set(imageURL: nil, withPlaceholder: nil, completion: nil)
//        }
//
    }
    
    
    enum LiveViewState {
        
        case loading(UIViewController)
        case live(BCOVPlaylist)
        case offAir(UIViewController)
    }
}
