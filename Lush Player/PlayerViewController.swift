//
//  PlayerViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 05/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import ThunderRequestTV
import AVKit

/// The view controller displaying the programme player UI
/// Also responsible for playing playlists and managing the playlist schedule
class PlayerViewController: UIViewController {
    
    internal var controller: BCOVPlaybackController?
    
    var programme: Programme?
    
    var playlist: BCOVPlaylist?
    
    var controllerView: UIView?
    
    var brightcovePolicyKey: String?
    
    let brightcoveAccountId = BrightcoveConstants.accountID
    
    let avPlayerViewController = AVPlayerViewController()
    
    var playbackService: BCOVPlaybackService?
    
    var seekTime: TimeInterval?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard brightcovePolicyKey != nil else { return }
        
        addChildViewController(avPlayerViewController)
        avPlayerViewController.view.frame = view.bounds
        avPlayerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(avPlayerViewController.view)
        avPlayerViewController.didMove(toParentViewController: self)
        
        // If we have a playlist, then start playing
        if let playlist = playlist {
            
            // configure brightcove
            configureController()
            
            // Get the current playback position
            if let currentItem = playlist.playlistPosition {
                seekTime = currentItem.playbackStartTime
                self.controller?.setVideos([currentItem.scheduleItem.video] as NSFastEnumeration)
            } else {
                dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
        // If we have no programme then return
        guard let programme = programme else {
            return
        }
        
        // If the programme already has a GUID, then play it straight off
        if let _ = programme.guid {
            
            play(programme: programme)
            return
        }
        
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
            
            // Play the retuned programme
            self?.play(programme: programme)
        })
    }
    
    /// Plays a programme in the AVPlayerViewController
    ///
    /// - Parameter programme: The programme to start playings
    private func play(programme: Programme) {
        
        // Make sure programme has GUID again
        guard let guid = programme.guid else { return }
        
        // Configure brightcove controller
        configureController()
        
        // Set up the playback service and search for video
        playbackService = BCOVPlaybackService(accountId: brightcoveAccountId, policyKey: brightcovePolicyKey)
        playbackService?.findVideo(withVideoID: guid, parameters: nil, completion: { (video, jsonResponse, error) in
            
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
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        controllerView?.frame = view.bounds
    }
}

extension PlayerViewController: BCOVPlaybackControllerDelegate {
    
    func playbackController(_ controller: BCOVPlaybackController!, didCompletePlaylist playlist: NSFastEnumeration!) {
        
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
        
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Called when the BCOVPlaybackController starts playing content
    ///
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        
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
