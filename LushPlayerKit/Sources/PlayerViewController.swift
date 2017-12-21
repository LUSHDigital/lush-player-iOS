//
//  PlayerViewController.swift
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
#if os(iOS)
    import ThunderRequest
#elseif os(tvOS)
    import ThunderRequestTV
#endif
import AVKit


/// The view controller displaying the programme player UI
/// Also responsible for playing playlists and managing the playlist schedule
public class PlayerViewController: UIViewController {
    
    public var controller: BCOVPlaybackController?
    
    public var programme: Programme?
    
    public var playlist: BCOVPlaylist?
    
    public var controllerView: UIView?
    
    public var brightcovePolicyKey: String?
    
    public let brightcoveAccountId = BrightcoveConstants.accountID
    
    public let avPlayerViewController = AVPlayerViewController()
    
    public var playbackService: BCOVPlaybackService?
    
    public var seekTime: TimeInterval?
    
    public var shouldAutoPlay: Bool = true

    @IBOutlet public weak var activityIndicator: UIActivityIndicatorView!
    
    public var shouldDismissOnVideoEnd: Bool = true
    
    public var videoFinished: Bool = false
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard brightcovePolicyKey != nil else { return }
        
        addChildViewController(avPlayerViewController)
        avPlayerViewController.view.frame = view.bounds
        avPlayerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(avPlayerViewController.view)
        avPlayerViewController.didMove(toParentViewController: self)
        
        // If we have a playlist, then start playing
        if let playlist = playlist {
            play(playlist: playlist)
        }
        
        
        // If we have no programme then return
        guard let programme = programme else {
            return
        }
        
        // If the programme already has a GUID, then play it straight off
        if let _ = programme.guid {
            
            if shouldAutoPlay {
                play(programme: programme)
                return
            }
        }
        
        fetch(programme: programme) { [weak self] (error, programme) in
            
            if let error = error {
                print(error)
            }
            
            if let programme = programme {
                // Play the retuned programme
                if let welf = self, welf.shouldAutoPlay {
                    welf.play(programme: programme)
                }
            }
        }
        
    }
    
    
    deinit {
        avPlayerViewController.player?.pause()
        avPlayerViewController.view.removeFromSuperview()
        avPlayerViewController.player = nil
    }
    
    public func play(playlist: BCOVPlaylist) {
        
            // configure brightcove
            configureController()
            
            // Get the current playback position
            if let currentItem = playlist.playlistPosition {
                seekTime = currentItem.playbackStartTime
                self.controller?.setVideos([currentItem.scheduleItem.video] as NSFastEnumeration)
            } else {
                dismiss(animated: true, completion: nil)
            }
    }
    
    
    private func fetch(programme: Programme, completion: @escaping ((Error?, Programme?) -> ())) {
        
        // If we don't have a GUID for the programme, then fetch details from endpoint
        LushPlayerController.shared.fetchDetails(for: programme, with: { [weak self] (error: Error?, programme: Programme?) in
            
            // Present any errors
            if let _error = error {
                
                let alertController = UIAlertController(error: _error)
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            // Didn't get a programme
            guard let programme = programme else {
                return
            }
            
            completion(error, programme)
        })
    }
    
    /// Plays a programme in the AVPlayerViewController
    ///
    /// - Parameter programme: The programme to start playings
    public func play(programme: Programme) {
        
        // Make sure programme has GUID again
        guard let guid = programme.guid else {
            
            fetch(programme: programme, completion: { [weak self] (error, programme) in
                
                if let error = error {
                    print(error)
                }
                
                if let programme = programme {
                    // Play the retuned programme
                    self?.play(programme: programme)
                }
            })
            
            return
        }
        
        // Configure brightcove controller
        configureController()
        
        // Set up the playback service and search for video
        playbackService = BCOVPlaybackService(accountId: brightcoveAccountId, policyKey: brightcovePolicyKey)
        playbackService?.findVideo(withVideoID: guid, parameters: nil, completion: { (video, jsonResponse, error) in
            
            if let error = error {
                
                var showGeoError: Bool = false
                
                // We need to check for a geoblocked error but its hella nested
                if let playbackErrors = (error as NSError).userInfo[kBCOVPlaybackServiceErrorKeyAPIErrors] as? [[AnyHashable: Any]] {
                    showGeoError = playbackErrors.contains(where: { ($0["error_subcode"] as? String) == "CLIENT_GEO" })
                }
                
                let message = showGeoError ? "This video has not been made available in your area" : "This video is not currently available"
                
                let alertController = UIAlertController(title: "Video Unavailable", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            // Make sure we get a video back
            guard let video = video else { return }
            
            // Set the brightcove controller's videos
            OperationQueue.main.addOperation ({
                self.controller?.setVideos([video] as NSFastEnumeration)
            })
        })

    }
    
    
    /// Sets up the brightcove controller
    private func configureController() {
        
        let manager = BCOVPlayerSDKManager.shared()
        
        // Set up source options to stream HLS over HTTPS
        let options = BCOVBasicSessionProviderOptions()
        options.sourceSelectionPolicy = BCOVBasicSourceSelectionPolicy.sourceSelectionHLS(withScheme: kBCOVSourceURLSchemeHTTPS)
        let provider = manager?.createBasicSessionProvider(with: options)
        
        let controller = BCOVPlayerSDKManager.shared().createPlaybackController(with: provider, viewStrategy: nil)
        self.controller = controller

        // Allow background audio and enable auto-advance
        controller?.allowsBackgroundAudioPlayback = true
        controller?.delegate = self
        controller?.isAutoAdvance = true
    }
    
    override public func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        controllerView?.frame = view.bounds
    }
}

extension PlayerViewController: BCOVPlaybackControllerDelegate {
    
    public func playbackController(_ controller: BCOVPlaybackController!, didCompletePlaylist playlist: NSFastEnumeration!) {
        
        // If we have a playlist
        if let videoPlaylist = self.playlist {
            
            // Get the current item in the playlist and play it
            if let currentItem = videoPlaylist.playlistPosition {
                controller?.setVideos([currentItem.scheduleItem.video] as NSFastEnumeration)
            } else {
                // If we don't have a playlist any more, then dismiss ourselves
                dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
        if shouldDismissOnVideoEnd {
            dismiss(animated: true, completion: nil)
        }
        
        videoFinished = true
    }
    
    
    /// Called when the BCOVPlaybackController starts playing content
    ///
    public func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        
        // Make sure we're on the main thread
        OperationQueue.main.addOperation({
            
            // Pause the player, and then set our AVPlayerViewController's player to the session's player
            session.player.pause()
            self.avPlayerViewController.player = session.player
            
            // If we have a seek time based on the playlist info
            if let seekTime = self.seekTime {
                
                // Seek to the correct point
                let newTime = CMTime(seconds: seekTime, preferredTimescale: 1)
                session.player.seek(to: newTime)
                session.player.play()
                
                
            } else if let seekTime = self.playlist?.playlistPosition?.playbackStartTime { // Or we have a playlist with a playback start time
                
                // Seek to the correct point
                let newTime = CMTime(seconds: seekTime, preferredTimescale: 1)
                session.player.seek(to: newTime)
                session.player.play()
                
            } else { // Otherwise just start playing
                
                session.player.play()

            }
        })
    }
}
