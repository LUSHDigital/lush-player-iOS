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
        
        if let playlist = playlist {
            
            configureController()
            
            if let currentItem = playlist.playlistPosition {
                seekTime = currentItem.playbackStartTime
                self.controller?.setVideos([currentItem.scheduleItem.video] as NSFastEnumeration)
            } else {
                dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
        guard let programme = programme else {
            return
        }
        
        if let _ = programme.guid {
            
            play(programme: programme)
            return
        }
        
        LushPlayerController.shared.fetchDetails(for: programme, with: { [weak self] (error: Error?, programme: Programme?) in
            
            if let _error = error {
                
                let alertController = UIAlertController(error: _error)
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            guard let programme = programme else {
                return
            }
            
            self?.play(programme: programme)
        })
    }
    
    private func play(programme: Programme) {
        
        guard let guid = programme.guid else { return }
        
        configureController()
        
        playbackService = BCOVPlaybackService(accountId: brightcoveAccountId, policyKey: brightcovePolicyKey)
        playbackService?.findVideo(withVideoID: guid, parameters: nil, completion: { (video, jsonResponse, error) in
            
            guard let video = video else { return }
            
            //                guard let source = video.sources.first as? BCOVSource else { return }
            
            //                OperationQueue.main.addOperation {
            //
            //                    let player = AVPlayer(url: source.url)
            //                    self?.avPlayerViewController.player = player
            //                    player.play()
            //                }
            
            OperationQueue.main.addOperation ({
                self.controller?.setVideos([video] as NSFastEnumeration)
            })
        })

    }
    
    private func configureController() {
        
        let manager = BCOVPlayerSDKManager.shared()
        
        let options = BCOVBasicSessionProviderOptions()
        options.sourceSelectionPolicy = BCOVBasicSourceSelectionPolicy.sourceSelectionHLS(withScheme: kBCOVSourceURLSchemeHTTPS)
        let provider = manager?.createBasicSessionProvider(with: options)
        
        let controller = BCOVPlayerSDKManager.shared().createPlaybackController(with: provider, viewStrategy: nil)
        self.controller = controller
        
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
        
        if let videoPlaylist = self.playlist {
            
            if let currentItem = videoPlaylist.playlistPosition {
                controller?.setVideos([currentItem.scheduleItem.video] as NSFastEnumeration)
            } else {
                dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        
        OperationQueue.main.addOperation({
            
            session.player.pause()
            self.avPlayerViewController.player = session.player
            
            if let seekTime = self.seekTime {
                
                let newTime = CMTime(seconds: seekTime, preferredTimescale: 1)
                session.player.seek(to: newTime)
                session.player.play()
                
            } else if let seekTime = self.playlist?.playlistPosition?.playbackStartTime {
                
                let newTime = CMTime(seconds: seekTime, preferredTimescale: 1)
                session.player.seek(to: newTime)
                session.player.play()
                
            } else {
                
                session.player.play()

            }
        })
    }
}
