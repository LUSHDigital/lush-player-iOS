//
//  PlayerViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 05/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import ThunderRequestTV

class PlayerViewController: UIViewController {
    
    private var controller: BCOVPlaybackController?
    
    var programme: Programme?
    
    var playlistID: String?
    
    var controllerView: UIView?
    
    let brightcovePolicyKey = ""
    
    let brightcoveAccountId = ""
    
    var playbackService: BCOVPlaybackService?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let playlistID = playlistID {
            
            let controller = BCOVPlayerSDKManager.shared().createPlaybackController()
            self.controller = controller
            
            if let controller = controller {
                
                view.addSubview(controller.view)
                controller.view.frame = view.bounds
            }
            
            playbackService = BCOVPlaybackService(accountId: brightcoveAccountId, policyKey: brightcovePolicyKey)
            
            playbackService?.findPlaylist(withPlaylistID: playlistID, parameters: nil, completion: { (playlist, jsonResponse, error) in
                
                guard let videos = playlist?.videos as? NSFastEnumeration else {
                    return
                }
                
                controller?.setVideos(videos)
                controller?.play()
            })
            
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
            
            let controller = BCOVPlayerSDKManager.shared().createPlaybackController()
            self?.controller = controller
            
            if let controller = controller {
                self?.view.addSubview(controller.view)
                
                if let view = self?.view {
                    controller.view.frame = view.bounds
                }
            }
            
            guard let welf = self else { return }
            
            welf.playbackService = BCOVPlaybackService(accountId: welf.brightcoveAccountId, policyKey: welf.brightcovePolicyKey)
            welf.playbackService?.findVideo(withVideoID: guid, parameters: nil, completion: { (video, jsonResponse, error) in
                
                guard let video = video else { return }
                controller?.setVideos([video] as NSFastEnumeration)
                controller?.play()
            })
        })
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        controllerView?.frame = view.bounds
    }
}
