//
//  SecondViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class GradientView : UIView {
    
    var gradientLayer: CAGradientLayer? {
        get {
            return layer as? CAGradientLayer
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 0)
    }
    
    /// Adds a horizontal gradient to the full-size of the view
    ///
    /// - Parameters:
    ///   - colors: The colors that the gradient should move through
    ///   - locations: The fractional position that each colour should appear at
    func setGradient(with colors: [UIColor], locations: [CGFloat]? = nil) {
        
        gradientLayer?.colors = colors.map({$0.cgColor})
        if let locations = locations {
            gradientLayer?.locations = locations.map({NSNumber(value: Float($0))})
        }
    }
}

extension BCOVPlaylist {
    
    var currentVideo: BCOVVideo? {
        get {
            
            // First make sure our videos array are actually BCOVVideo objects
            guard let videos = videos as? [BCOVVideo] else { return nil }
            
            let timezoneOffset = (TimeZone.current.secondsFromGMT(for: Date()) / 60)
            
            return videos.first(where: { (video) -> Bool in
                
                guard let customInfo = video.properties["custom_fields"] as? [AnyHashable : Any] else { return false }
                guard let liveDuration = customInfo["livebroadcastlength"] as? String, let startTime = customInfo["starttime"] as? String else { return false }
                
                return true
            })
        }
    }
}

class LiveViewController: UIViewController {

    var playbackService: BCOVPlaybackService?
    
    var playlist: BCOVPlaylist?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var watchButton: TSCButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var liveView: TSCView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var gradientView: GradientView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        redraw()
        refresh()
    }
    
    @IBAction func handleWatch(_ sender: Any) {
        
    }
    
    func refresh() {
        
        self.loadingIndicator.startAnimating()
        
        LushPlayerController.shared.fetchLivePlaylist(with: nil, completion: { [weak self] (error, playlistID) in
            
            if let error = error, let welf = self {
                
                if let lushError = error as? LushPlayerError {
                    switch lushError {
                    case .emptyResponse:
                        print("No Live Playlist")
                    case .invalidResponse, .invalidResponseStatus:
                        UIAlertController.presentError(error, in: welf)
                    }
                } else {
                    UIAlertController.presentError(error, in: welf)
                }
            }
            
            self?.loadingIndicator.stopAnimating()
            
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

    }

    func redraw() {
        
        guard let playlist = playlist, let video = playlist.currentVideo else {
            
            titleLabel.isHidden = true
            timeLabel.isHidden = true
            watchButton.isHidden = true
            liveView.isHidden = true
            imageView.image = nil
            
            return
        }
        
        if titleLabel.isHidden == true {
            
            UIView.animate(withDuration: 0.4, animations: { 
                
                self.titleLabel.isHidden = false
                self.timeLabel.isHidden = false
                self.watchButton.isHidden = false
                self.liveView.isHidden = false
            })
        }
        
        titleLabel.text = video.properties["name"] as? String
        
        if let posterString = video.properties["poster"] as? String, let posterURL = URL(string: posterString) {
            imageView.set(imageURL: posterURL, withPlaceholder: nil, completion: nil)
        } else {
            imageView.set(imageURL: nil, withPlaceholder: nil, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        gradientView.setGradient(with: [UIColor.black, UIColor.clear], locations: [0.0, 1.0])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let programme = sender as? Programme else { return }
        guard let playerVC = segue.destination as? PlayerViewController else { return }
        
        playerVC.brightcovePolicyKey = BrightcoveConstants.livePolicyID
        playerVC.programme = programme
    }
}

