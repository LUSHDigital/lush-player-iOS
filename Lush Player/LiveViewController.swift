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

extension BCOVPlaylist {
    
    func schedule(relative toDate: Date = Date()) -> [(video: BCOVVideo, startDate: Date, endDate: Date)] {
        
        return videos.flatMap({ (video) -> (video: BCOVVideo, startDate: Date, endDate: Date)? in
            
            guard let _video = video as? BCOVVideo else { return nil }
            
            guard let customInfo = _video.properties["custom_fields"] as? [AnyHashable : Any] else { return nil }
            guard let liveDuration = customInfo["livebroadcastlength"] as? String, let startTime = customInfo["starttime"] as? String else { return nil }
            
            // Set up date formatters
            let durationFormatter = DateFormatter()
            durationFormatter.dateFormat = "HH:mm:ss"
            
            let startFormatter = DateFormatter()
            startFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            // Create duration date object and start date object from date formatters
            guard let durationDate = durationFormatter.date(from: liveDuration), let startDate = startFormatter.date(from: startTime) else { return nil }
            
            let components: Set<Calendar.Component> = [.minute, .hour, .second]
            
            // The date components of the date to return relative start/end dates from
            let relativeComponents = Calendar.current.dateComponents(components, from: toDate)
            
            // Change start date back from API so it retains it's time, but takes the day/year/month from our relative date
            var startComponents = Calendar.current.dateComponents(components, from: startDate)
            startComponents.year = relativeComponents.year
            startComponents.month = relativeComponents.month
            startComponents.day = relativeComponents.day
            
            let durationComponents = Calendar.current.dateComponents(components, from: durationDate)
            
            guard let relativeStartDate = Calendar.current.date(from: startComponents) else { return nil }
            
            // Get the time interval through the day from durationComponents, the current time as a date using the same normalisation as for startTimeDate
            guard let interval = durationComponents.timeIntervalSinceStartOfDay else { return nil }
            
            // Calculate the end date of the video
            let endDate = relativeStartDate.addingTimeInterval(interval)
            return (_video, relativeStartDate, endDate)
        })
    }
    
    var playlistPosition: (scheduleItem: (video: BCOVVideo, startDate: Date, endDate: Date), playbackStartTime: TimeInterval)? {
        get {
            
            // First make sure our videos array are actually BCOVVideo objects
            
            let scheduleArray = schedule()
            var playbackStartTime: TimeInterval = 0
            let currentDate = Date()
            
            guard let currentVideo = scheduleArray.first(where: { (schedule) -> Bool in
                
                // Return whether the current date falls during the time of the show
                if currentDate > schedule.startDate && currentDate < schedule.endDate {
                    playbackStartTime = currentDate.timeIntervalSince(schedule.startDate)
                    return true
                } else {
                    return false
                }
            }) else { return nil }
            
            return (currentVideo, playbackStartTime)
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
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        redraw()
        refresh()
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

    func redraw() {
        
        redrawTimer?.invalidate()
        
        if let programme = programme {
            
            liveView.isHidden = true
            titleLabel.text = programme.title
            descriptionLabel.text = programme.description
            imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
            dateLabel.text = programme.dateString
            
        } else {
            
            guard let playlist = playlist, let playlistPosition = playlist.playlistPosition else {
                
                titleLabel.isHidden = true
                timeLabel.isHidden = true
                watchButton.isHidden = true
                liveView.isHidden = true
                imageView.image = nil
                
                return
            }
            
            redrawTimer = Timer(fire: playlistPosition.scheduleItem.endDate, interval: 0, repeats: false, block: { [weak self] (timer) in
                self?.redraw()
            })
            
            if titleLabel.isHidden == true {
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.titleLabel.isHidden = false
                    self.timeLabel.isHidden = false
                    self.watchButton.isHidden = false
                    self.liveView.isHidden = false
                })
            }
            
            let video = playlistPosition.scheduleItem.video
            titleLabel.text = video.properties["name"] as? String
            
            if let posterString = video.properties["poster"] as? String, let posterURL = URL(string: posterString) {
                imageView.set(imageURL: posterURL, withPlaceholder: nil, completion: nil)
            } else {
                imageView.set(imageURL: nil, withPlaceholder: nil, completion: nil)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        gradientView.setGradient(with: [UIColor.black, UIColor.clear], locations: [0.0, 1.0])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let programme = sender as? Programme else {
        
            //TODO: Logic to play from live playlist
            
            return
        }
        
        guard let playerVC = segue.destination as? PlayerViewController else { return }
        
        playerVC.brightcovePolicyKey = BrightcoveConstants.onDemandPolicyID
        playerVC.programme = programme
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
                    
                    welf.playAudio(from: programmeFile)
                })
                
                return
            }
            
            playAudio(from: file)
        }
    }
    
    func play(playlist: BCOVPlaylist) {
        
        
    }
    
    private func playAudio(from url: URL) {
        
        let avPlayerViewController = AVPlayerViewController()
        let avPlayer = AVPlayer(url: url)
        avPlayerViewController.player = avPlayer
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        present(avPlayerViewController, animated: true, completion: {
            avPlayer.play()
        })
    }
}

