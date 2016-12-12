//
//  SecondViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import AVKit

extension DateComponents {
    
    var timeIntervalSinceStartOfDay: TimeInterval? {
        get {
            guard let hour = hour, let minute = minute, let second = second else { return nil }
            return (Double(hour) * 3600.0) + (Double(minute) * 60.0) + Double(second)
        }
    }
}

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


/// This view controller is designed for the LIVE tab of the app, however as it is similar in UI and logic to the
/// programme details view it can be re-used for that by setting `programme` to a non-nil value.
class LiveViewController: UIViewController {

    var playbackService: BCOVPlaybackService?
    
    var playlist: BCOVPlaylist?
    
    var programme: Programme?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var watchButton: TSCButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var liveView: TSCView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var descriptionRemainingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundPlayerView: PlayerView!
    @IBOutlet weak var noBroadcastLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        
        self.loadingIndicator.startAnimating()
        
        if let programme = programme {
            
            watchButton.isEnabled = false
            watchButton.alpha = 0.6
            
            refresh(programme: programme)
            
            if programme.media == .TV {
                watchButton.setTitle("PLAY", for: .normal)
            } else {
                watchButton.setTitle("LISTEN", for: .normal)
            }
            
        } else {
            refreshLive()
        }
    }
    
    private func refreshLive() {
        
        LushPlayerController.shared.fetchLivePlaylist(with: nil, completion: { [weak self] (error, playlistID) in
            
            self?.loadingIndicator.stopAnimating()
            
            if let error = error, let welf = self {
                
                if let lushError = error as? LushPlayerError {
                    switch lushError {
                    case .emptyResponse:
                        print("No Live Playlist")
                        // Still redraw so we get fallback video
                        self?.redraw()
                    case .invalidResponse, .invalidResponseStatus:
                        UIAlertController.presentError(error, in: welf)
                    }
                } else {
                    UIAlertController.presentError(error, in: welf)
                }
            }
            
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
    
    private func refresh(programme: Programme) {
        
        LushPlayerController.shared.fetchDetails(for: programme, with: { [weak self] (error, programme) in
            
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }

            if programme?.guid != nil {
                self?.watchButton.isEnabled = true
                self?.watchButton.alpha = 1.0
            }
            
            self?.loadingIndicator.stopAnimating()
            self?.redraw()
        })
    }
    
    /// A timer which will redraw the screen when the next programme in the playlist should be played
    var redrawTimer: Timer?
    var loopObserver: NSObjectProtocol?
    
    func playFallback() {
        
        guard let url = Bundle.main.url(forResource: "Holding Screen", withExtension: "mp4") else { return }
        if let _ = backgroundPlayerView.playerLayer?.player {
            return
        }
        
        noBroadcastLabel.isHidden = false
        containerView.isHidden = true
        gradientView.isHidden = true
        
        let player = AVPlayer(url: url)
        backgroundPlayerView.playerLayer?.player = player
        player.play()
        
        loopObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] notification in
            
            guard let player = notification.object as? AVPlayerItem, player == self?.backgroundPlayerView.playerLayer?.player?.currentItem else { return }
            
            self?.backgroundPlayerView.playerLayer?.player?.seek(to: kCMTimeZero)
            self?.backgroundPlayerView.playerLayer?.player?.play()
        }
    }
    
    func stopFallback() {
        
        noBroadcastLabel.isHidden = true
        if let player = backgroundPlayerView.playerLayer?.player {
            
            player.pause()
            backgroundPlayerView.playerLayer?.player = nil
            
            containerView.isHidden = false
            gradientView.isHidden = false
        }
    }

    func redraw() {
        
        redrawTimer?.invalidate()
        
        if let programme = programme {
            
            liveView.isHidden = true
            titleLabel.text = programme.title
            descriptionLabel.text = programme.description
            imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
            dateLabel.text = programme.dateString
            backgroundPlayerView.isHidden = true
            noBroadcastLabel.isHidden = true
            
            descriptionRemainingConstraint.constant = 0
            remainingLabel.text = nil
            
        } else {
            
            guard let playlist = playlist, let playlistPosition = playlist.playlistPosition else {
            
                titleLabel.isHidden = true
                timeLabel.isHidden = true
                watchButton.isHidden = true
                liveView.isHidden = true
                imageView.image = nil
                remainingLabel.isHidden = true
                descriptionLabel.isHidden = true
                playFallback()
                
                redrawTimer = Timer(fire: Date(timeIntervalSinceNow: 60), interval: 0, repeats: false, block: { [weak self] (timer) in
                    self?.refreshLive()
                })
                
                return
            }
            
            stopFallback()
            
            // Fire a timer 1 second after programme is scheduled to end, to redraw!
            remainingTimer?.invalidate()
            redrawTimer = Timer(fire: playlistPosition.scheduleItem.endDate.addingTimeInterval(1), interval: 0, repeats: false, block: { [weak self] (timer) in
                self?.redraw()
            })
            
            if titleLabel.isHidden == true {
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.titleLabel.isHidden = false
                    self.timeLabel.isHidden = false
                    self.watchButton.isHidden = false
                    self.liveView.isHidden = false
                    self.remainingLabel.isHidden = false
                    self.descriptionLabel.isHidden = false
                })
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mma"
            descriptionLabel.text = nil
            
            redrawRemainingLabel(playlistPosition: playlistPosition)
            
            dateLabel.text = "\(dateFormatter.string(from: playlistPosition.scheduleItem.startDate)) - \(dateFormatter.string(from: playlistPosition.scheduleItem.endDate))"
            
            let video = playlistPosition.scheduleItem.video
            titleLabel.text = video.properties["name"] as? String
            
            if let posterString = video.properties["poster"] as? String, let posterURL = URL(string: posterString) {
                imageView.set(imageURL: posterURL, withPlaceholder: nil, completion: nil)
            } else {
                imageView.set(imageURL: nil, withPlaceholder: nil, completion: nil)
            }
        }
    }
    
    var remainingTimer: Timer?
    
    /// Redraws the remaining time of the programme
    ///
    /// - Parameter playlistPosition: An option playlistPosition to draw from (if nil, this will be calculated)
    func redrawRemainingLabel(playlistPosition: (scheduleItem: (video: BCOVVideo, startDate: Date, endDate: Date), playbackStartTime: TimeInterval)? = nil) {
        
        guard let playlist = playlist else { return }

        let position = playlistPosition ?? playlist.playlistPosition
        guard let _position = position else { return }
        
        let remainingTime = _position.scheduleItem.endDate.timeIntervalSince(_position.scheduleItem.startDate) - _position.playbackStartTime
        
        remainingTimer?.invalidate()
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.includesTimeRemainingPhrase = true
        dateComponentsFormatter.unitsStyle = .short
        
        remainingLabel.text = dateComponentsFormatter.string(from: remainingTime)
        
        // Format remaining time
        if remainingTime > 24 * 60 * 60 {
            
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(24*60*60))+1)
            remainingTimer = Timer(fire: firstFireDate, interval: 24*60*60, repeats: true, block: { [weak self] (timer) in
                self?.redrawRemainingLabel()
            })
            
        } else if remainingTime > 60 * 60 {
            
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(60*60))+1)
            remainingTimer = Timer(fire: firstFireDate, interval: 60*60, repeats: true, block: { [weak self] (timer) in
                self?.redrawRemainingLabel()
            })
            
        } else if remainingTime > 60 {
            
            let firstFireDate = Date(timeIntervalSinceNow: remainingTime.truncatingRemainder(dividingBy:(60))+1)
            remainingTimer = Timer(fire: firstFireDate, interval: 60, repeats: true, block: { [weak self] (timer) in
                self?.redrawRemainingLabel()
            })
            
        } else {
            
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
        
        playerVC.brightcovePolicyKey = sender is Programme ? BrightcoveConstants.onDemandPolicyID : BrightcoveConstants.livePolicyID
        playerVC.programme = sender as? Programme
        playerVC.playlist = sender as? BCOVPlaylist
    }
    
    //MARK:
    //MARK: -
    
    func play(programme: Programme) {
        
        if (programme.media == .TV) {
            
            performSegue(withIdentifier: "PlayProgramme", sender: programme)
            
        } else if (programme.media == .radio) {
            
            guard let file = programme.file else {
                
                LushPlayerController.shared.fetchDetails(for: programme, with: { [weak self] (error, programme) -> (Void) in
                    
                    guard let welf = self else { return }
                    if let error = error {
                        UIAlertController.presentError(error, in: welf)
                    }
                    
                    guard let programmeFile = programme?.file else { return }
                    
                    welf.playAudio(from: programmeFile, with: programme?.thumbnailURL)
                })
                
                return
            }
            
            playAudio(from: file, with: programme.thumbnailURL)
        }
    }
    
    func play(playlist: BCOVPlaylist) {
        
        guard let _ = playlist.playlistPosition else { return }
        performSegue(withIdentifier: "PlayProgramme", sender: playlist)
    }
    
    private var endObserver: NSObjectProtocol?
    
    private func playAudio(from url: URL, with imageURL: URL?) {
        
        let avPlayerViewController = AVPlayerViewController()
        let avPlayer = AVPlayer(url: url)
        avPlayerViewController.player = avPlayer
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        endObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { (notification) in
            
            avPlayerViewController.dismiss(animated: true, completion: nil)
        })
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.set(imageURL: imageURL, withPlaceholder: nil, completion: nil)
        avPlayerViewController.contentOverlayView?.addSubview(imageView)
        
        present(avPlayerViewController, animated: true, completion: {
            avPlayer.play()
        })
    }
}
