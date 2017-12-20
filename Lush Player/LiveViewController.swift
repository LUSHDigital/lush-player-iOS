//
//  SecondViewController.swift
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
import AVKit
import LushPlayerKit


/// A view for displaying a colour gradient with ease
class GradientView : UIView {
    
    var gradientLayer: CAGradientLayer? {
        get {
            return layer as? CAGradientLayer
        }
    }
    
    // Make sure self.layer is kind of `CAGradientLayer` class
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Set up the gradient layer's start and end point
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


/// This view controller is designed for the LIVE tab of the app, however as it is similar in UI and logic to the
/// programme details view it can be re-used for that by setting `programme` to a non-nil value.
class LiveViewController: UIViewController {

    /// The brightcove playback service
    var playbackService: BCOVPlaybackService?
    
    /// The playlist to play live content from (If using as Live tab)
    var playlist: BCOVPlaylist?
    
    /// The programme to display in the UI (If using as programme details VC)
    var programme: Programme?
    
    /// The title label, used to display the programme title
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The label which displays the programme's description
    @IBOutlet weak var descriptionLabel: UILabel!
    
    /// A button which on press starts the current programme playing
    @IBOutlet weak var watchButton: TSCButton!
    
    /// A loading indicator centred on the view
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    /// The little round red live indicator when using as the Live tab
    @IBOutlet weak var liveView: TSCView!
    
    /// The image view used to display the programme thumbnail
    @IBOutlet weak var imageView: UIImageView!
    
    /// The gradient view used to merge the programme details into the thumbnail
    @IBOutlet weak var gradientView: GradientView!
    
    /// The container view for the programme details
    @IBOutlet weak var containerView: UIView!
    
    /// The label used to display the date of the programme
    @IBOutlet weak var dateLabel: UILabel!
    
    /// The label which displays the time remaining of the current live programme
    @IBOutlet weak var remainingLabel: UILabel!
    
    /// The layout constraint for the distance between the programme description 
    /// and the time remaining label, used to hide the time remaining label
    /// when this is being used as a programme detail view controller
    @IBOutlet weak var descriptionRemainingConstraint: NSLayoutConstraint!
    
    /// The player view used to play the live 'no content' video when no live contentcorld
    @IBOutlet weak var backgroundPlayerView: PlayerView!
    
    /// The label displaying that there's currently no live content
    @IBOutlet weak var noBroadcastLabel: UILabel!
    
    
    @IBOutlet weak var backdropView: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Redraw and refresh
        redraw()
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redraw()
    }
    
    @IBAction func handleWatch(_ sender: Any) {
        
        if let programme = programme {
            play(programme: programme)
        } else if let playlist = playlist {
            play(playlist: playlist)
        }
    }
    
    func refresh() {
        
        // Start the loading indicator
        self.loadingIndicator.startAnimating()
        
        // If we're being used as a programme details VC
        if let programme = programme {
            
            // Enable all correct UI
            watchButton.isEnabled = false
            watchButton.alpha = 0.6
            
            // Refresh the programme, in order to pull description
            refresh(programme: programme)
            
            // Update button title
            if programme.media == .TV {
                watchButton.setTitle("PLAY", for: .normal)
            } else {
                watchButton.setTitle("LISTEN", for: .normal)
            }
            
        } else {
            
            // Hit live playlist endpoint
            refreshLive()
        }
    }
    
    /// Refreshes live content from LUSH API
    private func refreshLive() {
        
        // Hit API
        LushPlayerController.shared.fetchLivePlaylist(with: nil, completion: { [weak self] (error, playlistID) in
            
            // Stop the loading indicator
            self?.loadingIndicator.stopAnimating()
            
            // If we have an error, handle it.
            if let error = error, let welf = self {
                
                if let lushError = error as? LushPlayerError {
                    switch lushError {
                    case .emptyResponse: // Handle empty response (No current live playlist)
                        // Still redraw so we get fallback video
                        self?.redraw()
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
            self?.playbackService = BCOVPlaybackService(accountId: BrightcoveConstants.accountID, policyKey: BrightcoveConstants.livePolicyID)
            
            // Find the playlist using the ID provided by LUSH API
            self?.playbackService?.findPlaylist(withPlaylistID: playlistID, parameters: nil, completion: { [weak self] (playlist, jsonResponse, error) in
                
                // If we got an error, show it!
                if let error = error, let welf = self {
                    UIAlertController.presentError(error, in: welf)
                }
                
                // Setup the playlist, and redraw the view
                self?.playlist = playlist
                self?.redraw()
            })
        })
    }
    
    /// Gets the programme details for the provided programme
    ///
    /// - Parameter programme: The programme to fetch details for
    private func refresh(programme: Programme) {
        
        // Hit the API
        LushPlayerController.shared.fetchDetails(for: programme, with: { [weak self] (error, programme) in
            
            // If we got an error, then show it!
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }

            // If the returned programme has a GUID, then enable the watch button
            if programme?.guid != nil {
                self?.watchButton.isEnabled = true
                self?.watchButton.alpha = 1.0
            }
            
            if let _programme = programme {
                self?.programme = _programme
            }
            
            // Setop the loading indicator, and redraw
            self?.loadingIndicator.stopAnimating()
            self?.redraw()
        })
    }
    
    /// A timer which will redraw the screen when the next programme in the playlist should be played
    var redrawTimer: Timer?
    
    /// An observer listening in for AVPlayerItemDidPlayToEndTime notifications
    var loopObserver: NSObjectProtocol?
    
    /// Plays the fallback video when no Live Playlist is available
    func playFallback() {
        
        // Find the video file from the bundle
        guard let url = Bundle.main.url(forResource: "Holding Screen", withExtension: "mp4") else { return }
        if let _ = backgroundPlayerView.playerLayer?.player {
            return
        }
        
        // Hide appropriate UI
        noBroadcastLabel.isHidden = false
        containerView.isHidden = true
        gradientView.isHidden = true
        backdropView.isHidden = true
        
        // Set up the player with the video file from the bundle
        let player = AVPlayer(url: url)
        backgroundPlayerView.playerLayer?.player = player
        player.play()
        
        // Set up a loop observer to loop the fallback video
        loopObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] notification in
            
            // Make sure the notification was for the correct AVPlayerItem
            guard let player = notification.object as? AVPlayerItem, player == self?.backgroundPlayerView.playerLayer?.player?.currentItem else { return }
            
            // Restart the fallback video
            self?.backgroundPlayerView.playerLayer?.player?.seek(to: kCMTimeZero)
            self?.backgroundPlayerView.playerLayer?.player?.play()
        }
    }
    
    /// Stops the live fallback video from playing
    func stopFallback() {
        
        // Hide the no broadcast label
        noBroadcastLabel.isHidden = true
        
        if let player = backgroundPlayerView.playerLayer?.player {
            
            // Pause and remove the video
            player.pause()
            backgroundPlayerView.playerLayer?.player = nil
            
            // Show the live UI
            containerView.isHidden = false
            containerView.isHidden = false
            gradientView.isHidden = false
            backdropView.isHidden = false
        }
    }

    func redraw() {
        
        // Invalidate redraw timer
        redrawTimer?.invalidate()
        
        // If we're being used as programme details VC
        if let programme = programme {
            
            // Hide the live view
            liveView.isHidden = true
            
            // Setup all UI
            titleLabel.text = programme.title
            descriptionLabel.text = programme.description
            imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
            dateLabel.text = programme.dateString
            backgroundPlayerView.isHidden = true
            noBroadcastLabel.isHidden = true
            
            // Hide the remaining time label using layout constraints
            descriptionRemainingConstraint.constant = 0
            remainingLabel.text = nil
            
        } else {
            
            // Make sure we have a playlist, and also a position within it to play from
            guard let playlist = playlist, let playlistPosition = playlist.playlistPosition else {
            
                // Hide all UI as we're now playing fallback video :(
                titleLabel.isHidden = true
                dateLabel.isHidden = true
                watchButton.isHidden = true
                liveView.isHidden = true
                imageView.image = nil
                remainingLabel.isHidden = true
                descriptionLabel.isHidden = true
                
                // Start playing fallback video
                playFallback()
                
                // Check every 60 seconds for live playlist content!
                redrawTimer = Timer(fire: Date(timeIntervalSinceNow: 60), interval: 0, repeats: false, block: { [weak self] (timer) in
                    self?.refreshLive()
                })
                
                return
            }
            
            // We got a playlist, so stop playing fallback video
            stopFallback()
            
            // Fire a timer 1 second after programme is scheduled to end, to redraw!
            remainingTimer?.invalidate()
            redrawTimer = Timer(fire: playlistPosition.scheduleItem.endDate.addingTimeInterval(1), interval: 0, repeats: false, block: { [weak self] (timer) in
                self?.redraw()
            })
            
            // Show all UI in a nice animated fashion
            if titleLabel.isHidden == true {
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.titleLabel.isHidden = false
                    self.dateLabel.isHidden = false
                    self.watchButton.isHidden = false
                    self.liveView.isHidden = false
                    self.remainingLabel.isHidden = false
                    self.descriptionLabel.isHidden = false
                })
            }
            
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
            
            // If we have a poster url on the video object, display it in background
            if let posterString = video.properties["poster"] as? String, let posterURL = URL(string: posterString) {
                imageView.set(imageURL: posterURL, withPlaceholder: nil, completion: nil)
            } else {
                imageView.set(imageURL: nil, withPlaceholder: nil, completion: nil)
            }
        }
    }
    
    /// A timer to trigger when the remaining time of the programme has elapsed
    var remainingTimer: Timer?
    
    /// Redraws the remaining time of the programme
    ///
    /// - Note: This is also responsible for setting up the Timer object to redraw the view when the next live video should be displayed
    ///
    /// - Parameter playlistPosition: An option playlistPosition to draw from (if nil, this will be calculated)
    func redrawRemainingLabel(playlistPosition: (scheduleItem: (video: BCOVVideo, startDate: Date, endDate: Date), playbackStartTime: TimeInterval)? = nil) {
        
        // Make sure we have a playlist, and a position within it
        guard let playlist = playlist else { return }

        let position = playlistPosition ?? playlist.playlistPosition
        guard let _position = position else { return }
        
        // Calculate remaining time of current video
        let remainingTime = _position.scheduleItem.endDate.timeIntervalSince(_position.scheduleItem.startDate) - _position.playbackStartTime
        
        // Invalidate timer
        remainingTimer?.invalidate()
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.includesTimeRemainingPhrase = true
        dateComponentsFormatter.unitsStyle = .short
        
        // Set up remaining time label text using formatter
        remainingLabel.text = dateComponentsFormatter.string(from: remainingTime)
        
        // Make sure the remaining label refreshes at the appropriate time intervals
        // If more than 24 hours left, then set up the timer to refresh remaining label in 24 hours
        if remainingTime > 24 * 60 * 60 {
            
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(24*60*60))+1)
            remainingTimer = Timer(fire: firstFireDate, interval: 24*60*60, repeats: true, block: { [weak self] (timer) in
                self?.redrawRemainingLabel()
            })
            
        } else if remainingTime > 60 * 60 {
            
            // If longer than an hour left refresh the remaining label every hour
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(60*60))+1)
            remainingTimer = Timer(fire: firstFireDate, interval: 60*60, repeats: true, block: { [weak self] (timer) in
                self?.redrawRemainingLabel()
            })
            
        } else if remainingTime > 60 {
            
            // If longer than 60 seconds left, refresh label every 60 seconds
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(60))+1)
            remainingTimer = Timer(fire: firstFireDate, interval: 60, repeats: true, block: { [weak self] (timer) in
                self?.redrawRemainingLabel()
            })
            
        } else {
            
            // If less than 60 seconds left, refresh label every second
            remainingTimer = Timer(fire: Date(timeIntervalSinceNow: 1), interval: 1, repeats: true, block: { [weak self] (timer) in
                self?.redrawRemainingLabel()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        gradientView.setGradient(with: [UIColor.black, UIColor.clear], locations: [0.0, 1.0])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let playerVC = segue.destination as? PlayerViewController else { return }
        
        // Make sure we use correct policy key based on whether we're the Live view or a programme details view
        playerVC.brightcovePolicyKey = sender is Programme ? BrightcoveConstants.onDemandPolicyID : BrightcoveConstants.livePolicyID
        playerVC.programme = sender as? Programme
        playerVC.playlist = sender as? BCOVPlaylist
    }
    
    //MARK:
    //MARK: -
    
    /// Plays a specific programme
    ///
    /// - Parameter programme: The programme to play
    func play(programme: Programme) {
        
        // If it's a TV programme, then push it using the segue
        if (programme.media == .TV) {
            
            performSegue(withIdentifier: "PlayProgramme", sender: programme)
            
        } else if (programme.media == .radio) {
            
            // If the programme is a radio programme, and there's no file on it, fetch the file
            guard let file = programme.file else {
                
                // Get the programme details
                LushPlayerController.shared.fetchDetails(for: programme, with: { [weak self] (error, programme) -> (Void) in
                    
                    // If we get an error, present it
                    guard let welf = self else { return }
                    if let error = error {
                        UIAlertController.presentError(error, in: welf)
                    }
                    
                    // Unfortunately we still don't have a file, this is an error with LUSH content.
                    guard let programmeFile = programme?.file else { return }
                    
                    // Play the audio file
                    welf.playAudio(from: programmeFile, with: programme?.thumbnailURL)
                })
                
                return
            }
            
            // If we got a file, then play it!
            playAudio(from: file, with: programme.thumbnailURL)
        }
    }
    
    
    /// Starts a playlist playing
    ///
    /// - Parameter playlist: The playlist to play
    func play(playlist: BCOVPlaylist) {
        
        // Double check that we have a position (This is calculated on the fly) before playing the playlist
        guard let _ = playlist.playlistPosition else { return }
        // Push the player UI
        performSegue(withIdentifier: "PlayProgramme", sender: playlist)
    }
    
    /// An observer listening into the end of a radio programme
    private var endObserver: NSObjectProtocol?
    
    /// Plays an audio file from a provided url, with a specified image url
    ///
    /// - Parameters:
    ///   - url: The url to play the audio file from
    ///   - imageURL: The image which represents the audio file
    private func playAudio(from url: URL, with imageURL: URL?) {
        
        // Setup an AVPlayerViewController
        let avPlayerViewController = AVPlayerViewController()
        let avPlayer = AVPlayer(url: url)
        avPlayerViewController.player = avPlayer
        
        // Try and mark us as playing Audio
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        // Set up an observer for when radio programme ends, this is used to dismiss the UI as tvOS doesn't handle this for us
        endObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { (notification) in
            
            // Make sure we're dismissing because of the correct AVPlayerItem
            guard let playerItem = notification.object as? AVPlayerItem else { return }
            if playerItem == avPlayerViewController.player?.currentItem {
                
                // Pause the player, nil it and then dismiss, this fixed an issue with rewinding radio programmes.
                avPlayerViewController.player?.pause()
                avPlayerViewController.player = nil
                avPlayerViewController.dismiss(animated: true, completion: nil)
            }
        })
        
        // Set up the image view for the radio programme and add it to the AVPlayerViewController contentOverlayView
        let imageView = UIImageView(frame: view.bounds)
        imageView.set(imageURL: imageURL, withPlaceholder: nil, completion: nil)
        avPlayerViewController.contentOverlayView?.addSubview(imageView)
        
        // present the AVPlayerViewController
        present(avPlayerViewController, animated: true, completion: {
            // Auto-start the radio programme
            avPlayer.play()
        })
    }
}
