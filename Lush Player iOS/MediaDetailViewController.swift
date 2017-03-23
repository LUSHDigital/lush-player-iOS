//
//  MediaDetailViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class MediaDetailViewController: UIViewController {
    
    // Model object programme that this view controller displays
    var programme: Programme!
    
    var mediaType: Programme.Media {
        get { return self.programme.media }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var mediaPlayerView: UIView!
    
    @IBOutlet weak var mediaTypeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var shareButton: SpacedCharacterButton!
    
    @IBOutlet weak var tagsContainerView: UIView!
    
    @IBOutlet weak var expandDescriptionButton: UIButton!
    
    @IBOutlet weak var playerContainerView: UIView!
    
    var tagListController: TagListCollectionViewController? {
        return childViewControllers.filter({ $0 is TagListCollectionViewController }).first as? TagListCollectionViewController
    }
    
    var mediaContentState: MediaContentState?


    @IBOutlet weak var tagListContainerHeight: NSLayoutConstraint!
    
    var descriptionExpansion: ExpansionState = .contracted
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMediaController()
        
        title = programme.title
        
        titleLabel.text = programme.title
        mediaTypeLabel.text = programme.media.displayString()
        descriptionLabel.text = programme.description
        dateLabel.text = programme.date?.timeAgo
        
        shareButton.setTitle("SHARE", for: .normal)
        if let tagListController = tagListController {
            
            if let tags = programme.tags {
                tagListController.tags = tags
            }
            tagListController.didSelectTag = { [weak self] tag in
                self?.selectedTag(tag: tag)
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let mediaContentState = mediaContentState {
            switch mediaContentState {
            case .TV(let playerViewController):
                playerViewController.view.frame = self.playerContainerView.bounds
            
            case .radio(let soundViewController):
                soundViewController.view.frame = self.playerContainerView.bounds
            }
        }
        
        // Don't show expand button if our text is truncated 
        if descriptionExpansion != .expanded {
            if !descriptionLabel.isTruncated() {
                descriptionExpansion = .notExpandable
                expandDescriptionButton.isHidden = true
            }
        }
        
        tagListContainerHeight.constant = tagListController?.collectionView?.contentSize.height ?? 128
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    
    /// Adds the relevant media controller for either TV or Radio, to the top of the view
    func addMediaController() {
        
        let placeholder = MediaPlaceholderView(frame: self.playerContainerView.bounds)
        placeholder.playButton.addTarget(self, action: #selector(playContent), for: .touchUpInside)
        placeholder.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
        
        switch programme.media {
        case .TV:
            if let playerViewController = storyboard?.instantiateViewController(withIdentifier: "PlayerViewControllerId") as? PlayerViewController {
                
                playerViewController.programme = programme
                playerViewController.brightcovePolicyKey = BrightcoveConstants.onDemandPolicyID
                
                addChildViewController(playerViewController)
                let bounds = self.playerContainerView.bounds
                playerViewController.view.frame = bounds
                self.playerContainerView.addSubview(playerViewController.view)
                
                self.mediaContentState = MediaContentState.TV(playerViewController)
                playerViewController.avPlayerViewController.view?.addSubview(placeholder)
                playerViewController.didMove(toParentViewController: self)
            }
            
        case .radio:
            if let playerViewController = storyboard?.instantiateViewController(withIdentifier: "SoundPlayerViewControllerId") as? SoundPlayerViewController {
            
                addChildViewController(playerViewController)
                let bounds = self.playerContainerView.bounds
                playerViewController.view.frame = bounds
                self.playerContainerView.addSubview(playerViewController.view)
                
                playerViewController.didMove(toParentViewController: self)
                playerViewController.view?.addSubview(placeholder)
//                playerViewController.play(programme: programme)
                self.mediaContentState = MediaContentState.radio(playerViewController)
            
            }
        }
    }
    
    func playContent() {
        
        if let mediaContentState = mediaContentState {
            switch mediaContentState {
            case .TV(let playerViewController):
                
                let placeholderView = playerViewController.avPlayerViewController.view.subviews.filter({ $0 is MediaPlaceholderView }).first
                playerViewController.avPlayerViewController.player?.play()
                UIView.animate(withDuration: 0.3, animations: { 
                    placeholderView?.alpha = 0.0
                }, completion: { (done) in
                    placeholderView?.isHidden = true
                    
                })
                
            case .radio(let soundViewController):
                let placeholderView = soundViewController.view.subviews.filter({ $0 is MediaPlaceholderView }).first
                soundViewController.play(programme: self.programme)
                UIView.animate(withDuration: 0.3, animations: {
                    placeholderView?.alpha = 0.0
                }, completion: { (done) in
                    placeholderView?.isHidden = true
                    
                })
               
            }
        }
        
    }
    
    func selectedTag(tag: String) {
        print(tag)
    }
    
    
    @IBAction func pressedExpandButton(_ sender: Any) {
        
        switch descriptionExpansion {
        case .contracted:
            UIView.animate(withDuration: 0.3, animations: {
                self.expandDescriptionButton.setTitle("Hide full description", for: .normal)
                self.descriptionLabel.numberOfLines = 0
                self.descriptionExpansion = .expanded
            })
        
        case .expanded:
            UIView.animate(withDuration: 0.3, animations: { 
                self.expandDescriptionButton.setTitle("Show full description", for: .normal)
                self.descriptionLabel.numberOfLines = 3
                self.descriptionExpansion = .contracted
            })

        case .notExpandable:
            return
        }
    }

    /// Share the media by presenting an activity share sheet
    @IBAction func shareMedia() {
        
        guard let url = programme.webURL else { return }
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    // Expansion state, used to know if the description is expanded or not, or notExpandable i.e the text isn't long enough to be expanded
    enum ExpansionState {
        
        case notExpandable
        case contracted
        case expanded
    }
    
    enum MediaContentState {
        
        case TV(PlayerViewController)
        case radio(SoundPlayerViewController)
    }
}
