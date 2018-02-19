//
//  LiveViewController.swift
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
    
    // View containing the tags controller
    @IBOutlet weak var tagsContainerView: UIView!
    
    // Parent tag view containing the tag list and a title
    @IBOutlet weak var tagsStackView: UIStackView!
    
    // Share button - opens activity sheet
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var liveIndicatorTitleLabel: UILabel!
    
    // Controller managing the tags of a video
    var tagListController: TagListCollectionViewController? {
        return childViewControllers.flatMap({ $0 as? TagListCollectionViewController }).first
    }
    
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
        
        
        shareButton.isHidden = true
        
        let attributedString = NSMutableAttributedString(string: liveIndicatorTitleLabel.text ?? "ON NOW", attributes: [NSAttributedStringKey.kern : CGFloat(1.5)])
        liveIndicatorTitleLabel.attributedText = attributedString

        shareButton.setTitle("SHARE", for: .normal)
        
        redraw()
        refreshLive()
    }
    
    // Check for new live stream every time we show the view controller
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshLive()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.playerViewController.avPlayerViewController.player?.pause()
    }
    
    @IBAction func pressedShare(sender: Any) {
        
        guard case .live = liveViewState else {
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.shareButton
        activityController.popoverPresentationController?.sourceRect = self.shareButton.frame
        
        activityController.completionWithItemsHandler = { activity, success, items, error in
            
            guard success else { return }
            guard error == nil else { return }
        }
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
        
        // Invalidate redraw timer
        redrawTimer?.invalidate()
        
       // Make sure we have a position within it to play from
        guard let playlistPosition = playlist.playlistPosition else {

            liveViewState = .offAir(offAirViewController)
            // Check every 60 seconds for live playlist content!
            if #available(iOS 10.0, *) {
                redrawTimer = Timer(fire: Date(timeIntervalSinceNow: 60), interval: 0, repeats: false, block: { [weak self] (timer) in
                    self?.refreshLive()
                })
            }
            return
        }
        
        
        self.playerViewController.play(playlist: playlist)

        // We got a playlist, so stop playing fallback video

        // Fire a timer 1 second after programme is scheduled to end, to redraw!
        if #available(iOS 10.0, *) {
            redrawTimer = Timer(fire: playlistPosition.scheduleItem.endDate.addingTimeInterval(2), interval: 0, repeats: false, block: { [weak self] (timer) in
                self?.redraw()
            })
            RunLoop.main.add(redrawTimer!, forMode: .defaultRunLoopMode)
        }

        // Show all UI in a nice animated fashion
        
        // date formatter for date label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mma"
        descriptionLabel.text = nil
        
        // Update remaining time label
        redrawRemainingLabel(playlistPosition: playlistPosition)
        
        // Update date label
        dateLabel.text = "\(dateFormatter.string(from: playlistPosition.scheduleItem.startDate)) - \(dateFormatter.string(from: playlistPosition.scheduleItem.endDate))"
        
        // Set title label to name of video
        let video = playlistPosition.scheduleItem.video
        titleLabel.text = video.properties["name"] as? String
        
        
        // Show description if available
        if let description = video.properties["description"] as? String {
            descriptionLabel.isHidden = false
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
        }
        
        // Placeholder for checking the url to share the video and show it when we know the property, for now lets just hide
        // TODO - Check for a url value when we know what the key is
        if false {
        } else {
            shareButton.isHidden = true
        }
        
        if let tagArray = video.properties["tags"] as? [String], !tagArray.isEmpty {
            
            let tags = tagArray.map({ Tag(name: $0, value: $0) })
            tagListController?.tags = tags
            
        } else {
            tagsStackView.isHidden = true
        }
    }
    
    /// A timer to trigger when the remaining time of the programme has elapsed
    var remainingTimer: Timer?
    
    ///
    var redrawTimer: Timer?
    
    
    /// Redraws the remaining time of the programme
    ///
    /// - Note: This is also responsible for setting up the Timer object to redraw the view when the next live video should be displayed
    ///
    /// - Parameter playlistPosition: An option playlistPosition to draw from (if nil, this will be calculated)
   func redrawRemainingLabel(playlistPosition: (scheduleItem: (video: BCOVVideo, startDate: Date, endDate: Date), playbackStartTime: TimeInterval)? = nil) {
        
        // Make sure we have a playlist, and a position within it
        guard case let .live(playlist) = liveViewState else { return }
        
        let position = playlistPosition ?? playlist.playlistPosition
        guard let _position = position else { return }
        
        // Calculate remaining time of current video
        let remainingTime = _position.scheduleItem.endDate.timeIntervalSince(_position.scheduleItem.startDate) - _position.playbackStartTime
        
        // Invalidate timer
        remainingTimer?.invalidate()
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.includesTimeRemainingPhrase = true
        dateComponentsFormatter.unitsStyle = .short
        dateComponentsFormatter.allowedUnits = [.hour, .minute]
    
        
        // Make sure the remaining label refreshes at the appropriate time intervals
        // If more than 24 hours left, then set up the timer to refresh remaining label in 24 hours
        if remainingTime > 24 * 60 * 60 {
            
            dateComponentsFormatter.allowedUnits = [.hour]
            timeRemainingLabel.text = dateComponentsFormatter.string(from: remainingTime)
            
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(24*60*60))+1)
            
            remainingTimer = Timer(fireAt: firstFireDate, interval: 60*60, target: self, selector: #selector(redrawRemainingLabel), userInfo: nil, repeats: true)
            
            
        } else if remainingTime > 60 * 60 {
            
            dateComponentsFormatter.allowedUnits = [.hour, .minute]
            timeRemainingLabel.text = dateComponentsFormatter.string(from: remainingTime)
            
            // If longer than an hour left refresh the remaining label every minute
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(60))+1)
            
            remainingTimer = Timer(fireAt: firstFireDate, interval: 60, target: self, selector: #selector(redrawRemainingLabel), userInfo: nil, repeats: true)
            
            
        } else if remainingTime > 60 {
            
            dateComponentsFormatter.allowedUnits = [.minute]
            timeRemainingLabel.text = dateComponentsFormatter.string(from: remainingTime)
            // If longer than 60 seconds left, refresh label every 60 seconds
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(60))+1)
            
            remainingTimer =  Timer(fireAt: firstFireDate, interval: 60, target: self, selector: #selector(redrawRemainingLabel), userInfo: nil, repeats: true)
            
        } else {
            dateComponentsFormatter.allowedUnits = [.second]
            timeRemainingLabel.text = dateComponentsFormatter.string(from: remainingTime)
            // If less than 60 seconds left, refresh label every second
            remainingTimer =  Timer(fireAt: Date(timeIntervalSinceNow: 1), interval: 1, target: self, selector: #selector(redrawRemainingLabel), userInfo: nil, repeats: true)
        }
    
        if let remainingTimer = remainingTimer {
             RunLoop.main.add(remainingTimer, forMode: .defaultRunLoopMode)
        }
    }
    
    @objc func redrawRemainingLabel() {
        redrawRemainingLabel(playlistPosition: nil)
    }
    
    
    enum LiveViewState {
        
        case loading(UIViewController)
        case live(BCOVPlaylist)
        case offAir(UIViewController)
    }
}
