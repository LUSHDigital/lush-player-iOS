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

class SoundPlayerViewController: ViewController {
    
    /// Plays a specific programme
    ///
    /// - Parameter programme: The programme to play
    func play(programme: Programme) {
        
        guard programme.media == .radio else { return }
        
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
        
        //        // Set up an observer for when radio programme ends, this is used to dismiss the UI as tvOS doesn't handle this for us
        //        endObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { (notification) in
        //
        //            // Make sure we're dismissing because of the correct AVPlayerItem
        //            guard let playerItem = notification.object as? AVPlayerItem else { return }
        //            if playerItem == avPlayerViewController.player?.currentItem {
        //
        //                // Pause the player, nil it and then dismiss, this fixed an issue with rewinding radio programmes.
        //                avPlayerViewController.player?.pause()
        //                avPlayerViewController.player = nil
        //                avPlayerViewController.dismiss(animated: true, completion: nil)
        //            }
        //        })
        
        // Set up the image view for the radio programme and add it to the AVPlayerViewController contentOverlayView
        let imageView = UIImageView(frame: view.bounds)
        imageView.set(imageURL: imageURL, withPlaceholder: nil, completion: nil)
        avPlayerViewController.contentOverlayView?.addSubview(imageView)
        self.addChildViewController(avPlayerViewController)
        avPlayerViewController.view.frame = self.view.bounds
        self.view.addSubview(avPlayerViewController.view)
        avPlayerViewController.didMove(toParentViewController: self)
        avPlayer.play()
    }
}

