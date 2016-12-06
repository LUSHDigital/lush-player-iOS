//
//  RefreshableViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import AVKit

class RefreshableViewController: UIViewController {
    
    private var refreshObserver: NSObjectProtocol?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        refresh()
        
        refreshObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.ProgrammesRefreshed, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            self?.redraw()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        
    }

    func redraw() {
        
    }
    
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
    
    private func playAudio(from url: URL) {
        
        let avPlayerViewController = AVPlayerViewController()
        let avPlayer = AVPlayer(url: url)
        avPlayerViewController.player = avPlayer
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        present(avPlayerViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let programme = sender as? Programme else { return }
        guard let playerVC = segue.destination as? PlayerViewController else { return }
        
        playerVC.programme = programme
    }
}
