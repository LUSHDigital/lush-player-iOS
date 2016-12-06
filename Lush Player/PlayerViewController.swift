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
    
    private var controller: BCOVPlaybackController?
    
    var programme: Programme?
    
    var playlist: BCOVPlaylist?
    
    var controllerView: UIView?
    
    var brightcovePolicyKey: String?
    
    let brightcoveAccountId = BrightcoveConstants.accountID
    
    let avPlayerViewController = AVPlayerViewController()
    
    var playbackService: BCOVPlaybackService?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let brightcovePolicyKey = brightcovePolicyKey else { return }
        
        addChildViewController(avPlayerViewController)
        avPlayerViewController.view.frame = view.bounds
        avPlayerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(avPlayerViewController.view)
        avPlayerViewController.didMove(toParentViewController: self)
        
        if let playlist = playlist {
            
            configureController()
            
            if let controller = controller {
                
                view.addSubview(controller.view)
                controller.view.frame = view.bounds
            }
            
            let videos = playlist.videos as NSFastEnumeration
            self.controller?.setVideos(videos)
            
            return
        }
        
        guard let programme = programme else {
            return
        }
        
        LushPlayerController.shared.fetchDetails(for: programme, with: { [weak self] (error: Error?, programme: Programme?) in
            
            if let _error = error {
                
                let alertController = UIAlertController(error: _error)
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            guard let guid = programme?.guid else {
                return
            }
            
            self?.configureController()
            
            guard let welf = self else { return }
            
            welf.playbackService = BCOVPlaybackService(accountId: welf.brightcoveAccountId, policyKey: brightcovePolicyKey)
            welf.playbackService?.findVideo(withVideoID: guid, parameters: nil, completion: { (video, jsonResponse, error) in
                
                guard let video = video else { return }
                self?.controller?.setVideos([video] as NSFastEnumeration)
//                self?.controller?.play()
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
        
        dismiss(animated: true, completion: nil)
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        
        avPlayerViewController.player = session.player
        avPlayerViewController.player?.play()
    }
}
