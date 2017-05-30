//
//  SoundPlayer.swift
//  Lush Player
//
//  Created by Joel Trew on 23/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import Foundation
import UIKit
import LushPlayerKit
import AVKit


/// View Controller for playing radio programs, this differs from the PlayerViewController as we simply stream the mp3 file
class SoundPlayerViewController: AVPlayerViewController {
    
    /// Thumbnail ImageView for displaying an image while the radio content plays
    var imageView: UIImageView!
    
    /// The currently playing programme, nil if unset
    var currentProgramme: Programme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView = UIImageView(frame: view.bounds)
        self.contentOverlayView?.addSubview(imageView)
        if let contentOverlayView = contentOverlayView {
            imageView.centerXAnchor.constraint(equalTo: contentOverlayView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentOverlayView.centerYAnchor).isActive = true
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 16/9, constant: 0))
            
            contentOverlayView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: contentOverlayView, attribute: .width, multiplier: 1.0, constant: 0))
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentOverlayView?.updateConstraints()
        
        // Observe PlayToEnd notification so we can log when the user finishes a programme
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil, using: { [weak self] (_) in
            
            guard let programme = self?.currentProgramme else { return }
            GATracker.trackEventWith(category: "End", action: programme.id, label: nil, value: nil)
        })
    }

    
    
    /// Plays a specific programme
    ///
    /// - Parameter programme: The programme to play
    func play(programme: Programme) {
        
        guard programme.media == .radio else { return }
        
        // Set as current programme
        self.currentProgramme = programme
        
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
    
    deinit {
        self.player?.pause()
        self.view.removeFromSuperview()
        self.player = nil
    }
    
    
    /// Plays an audio file from a provided url, with a specified image url
    ///
    /// - Parameters:
    ///   - url: The url to play the audio file from
    ///   - imageURL: The image which represents the audio file
    private func playAudio(from url: URL, with imageURL: URL?) {
        
        // Setup an AVPlayerViewController
        let avPlayer = AVPlayer(url: url)
        self.player = avPlayer
        
        // Try and mark us as playing Audio
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        // Set up the image view for the radio programme and add it to the AVPlayerViewController contentOverlayView
        
        imageView.set(imageURL: imageURL, withPlaceholder: nil, completion: nil)

        avPlayer.play()
    }
}

