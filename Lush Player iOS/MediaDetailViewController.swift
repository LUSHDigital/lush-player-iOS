//
//  MediaDetailViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

// A detailed view controller that appears when the user wants to watch or listen to a specific programme. This view controller contains either a child PlayerViewController or SoundPlayerViewController for playing respective programmes. It contains info about a specifc programme and displays a lost of tags
class MediaDetailViewController: UIViewController {
    
    // Model object programme that this view controller displays
    var programme: Programme!
    
    // The type of media the view controller is currently showing, computed from the programme object
    var mediaType: Programme.Media {
        get { return self.programme.media }
    }
    
    // Title label of the programme
    @IBOutlet weak var titleLabel: UILabel!
    
    // Label that displays the media type i.e Radio
    @IBOutlet weak var mediaTypeLabel: UILabel!
    
    // Label showing a short description of the programme
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Label showing how long ago the programme was uploaded
    @IBOutlet weak var dateLabel: UILabel!
    
    // Button that enables the user to share the programme, launches a native share sheet
    @IBOutlet weak var shareButton: SpacedCharacterButton!
    
    // View for containing the tagviewcontroller, which displays programme tags
    @IBOutlet weak var tagsContainerView: UIView!
    
    // Button that expands the description label, the description label initially displays a max of 3 lines
    @IBOutlet weak var expandDescriptionButton: UIButton!
    
    // View that contains the player
    @IBOutlet weak var playerContainerView: UIView!
    
    // Stackview containing the tag view
    @IBOutlet weak var tagsStackView: UIStackView!
    
    // Parent ScrollView containing all other views
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Loading view controller with a spinner
    lazy var loadingViewController: LoadingViewController = LoadingViewController()
    
    // Tag list view controller for showing the programme tags
    var tagListController: TagListCollectionViewController? {
        return childViewControllers.filter({ $0 is TagListCollectionViewController }).first as? TagListCollectionViewController
    }
    
    // The media state, TV or Radio with the player controller as an associated object
    var mediaContentState: MediaContentState?
    
    // A constraint for the tag list view controller, is changed depending on the number of items in the programmes tag array
    @IBOutlet weak var tagListContainerHeight: NSLayoutConstraint!
    
    // The current state of the description expansion, initially contracted/ limted to 3
    var descriptionExpansion: ExpansionState = .contracted
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMediaController()
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        // Model Programme -> UI set up
        title = programme.title
        titleLabel.text = programme.title
        mediaTypeLabel.text = programme.media.displayString()
        descriptionLabel.text = programme.description?.trimmingCharacters(in: .newlines)
        dateLabel.text = programme.date?.timeAgo
        
        shareButton.setTitle("SHARE", for: .normal)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mediaWillPlay, object: nil, queue: nil) { [weak self] (notification) in
            self?.stopMediaPlaying()
        }
        
        // Set up tags view, and callbacks
        if let tags = programme.tags, !tags.isEmpty {
            
            if let tagListController = tagListController {
                tagListController.tags = tags
                
                tagListController.didSelectTag = { [weak self] tag in
                    self?.selectedTag(tag)
                }
            }
            
        } else {
            // hide the tag view if theres no tags
            tagsStackView.isHidden = true
        }
        
        // Enable handoff
        if let url = programme.webURL {
            let webHandoffActivity = NSUserActivity(activityType: "com.lush.player.watching")
            webHandoffActivity.webpageURL = url
            userActivity = webHandoffActivity
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Don't show expand button if our text is not truncated
        if descriptionExpansion != .expanded {
            if !descriptionLabel.isTruncated() {
                descriptionExpansion = .notExpandable
                expandDescriptionButton.isHidden = true
            } else {
                descriptionExpansion = .contracted
                expandDescriptionButton.isHidden = false
            }
        }
        
        // Set the tag view container to the height of the tagListController as it has dynamic amount of items
        tagListContainerHeight.constant = tagListController?.collectionView?.contentSize.height ?? 128
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = false
        }
        
        GATracker.trackPage(named: "\(mediaType.displayString) programme \(programme.id)")
    }
    
    
    // Adds the relevant media controller for either TV or Radio, to the top of the view
    func addMediaController() {
        
        // Add a placeholder/thumbnail view before the user plays the video
        let placeholder = MediaPlaceholderView(frame: self.playerContainerView.bounds)
        placeholder.playButton.addTarget(self, action: #selector(playContent), for: .touchUpInside)
        placeholder.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
        
        // Setup TV or Radio players depending on the media type, this is done via child view controllers as we stream the video content from brightcove, but load straight from an mp3 file for radio content
        switch programme.media {
            
        // TV Setup
        case .TV:
            if let playerViewController = storyboard?.instantiateViewController(withIdentifier: "PlayerViewControllerId") as? PlayerViewController {
                
                playerViewController.programme = programme
                playerViewController.brightcovePolicyKey = BrightcoveConstants.onDemandPolicyID
                playerViewController.shouldAutoPlay = false
                playerViewController.shouldDismissOnVideoEnd = false
                
                addChildViewController(playerViewController)
                let bounds = self.playerContainerView.bounds
                playerViewController.view.frame = bounds
                self.playerContainerView.addSubview(playerViewController.view)
                
                self.mediaContentState = MediaContentState.TV(playerViewController)
                playerContainerView.addSubview(placeholder)
                placeholder.bindFrameToSuperviewBounds()
                playerViewController.didMove(toParentViewController: self)
                
                playerViewController.avPlayerViewController.contentOverlayView?.addObserver(self, forKeyPath: "bounds", options: [.old], context: nil)
                
            }
            
        // Radio Setup
        case .radio:
            if let playerViewController = storyboard?.instantiateViewController(withIdentifier: "SoundPlayerViewControllerId") as? SoundPlayerViewController {
                
                addChildViewController(playerViewController)
				
             //   let bounds = self.playerContainerView.bounds
             //   playerViewController.view.frame = bounds
				
				self.playerContainerView.translatesAutoresizingMaskIntoConstraints = false
                self.playerContainerView.addSubview(playerViewController.view)
				playerViewController.view.bindFrameToSuperviewBounds()
                playerViewController.didMove(toParentViewController: self)

				self.playerContainerView.addSubview(placeholder)
                placeholder.bindFrameToSuperviewBounds()
                
                playerViewController.contentOverlayView?.addObserver(self, forKeyPath: "bounds", options: [.old], context: nil)
                
                self.mediaContentState = MediaContentState.radio(playerViewController)
            }
        }
    }
    
    // Plays the media content, called when the user clicks the play button on the placeholder/thumbnail view
    func playContent() {
        
        // Remove the placeholder view
        togglePlaceholder(isHidden: true)
        
        NotificationCenter.default.post(name: NSNotification.Name.mediaWillPlay, object: nil)
        
        // Calle ach players respective play function to start the media
        if let mediaContentState = mediaContentState {
            
            switch mediaContentState {
                
            case .TV(let playerViewController):
                playerViewController.play(programme: self.programme)
                playerViewController.videoFinished = false
                
            case .radio(let soundViewController):
                soundViewController.play(programme: self.programme)
                
                // GA event - Played radio item
                GATracker.trackEventWith(category: "Play", action: programme.id, label: nil, value: nil)
            }
        }
    }
    
    // Show a tag list page when the user selects a specific tag
    func selectedTag(_ selectedTag: Tag) {
        
        self.performSegue(withIdentifier: "ShowTagId", sender: selectedTag)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowTagId" {
            
            guard let tag = sender as? Tag else { return }
            
            if let vc = segue.destination as? TagListViewController {
                
                vc.title = "Tag: #\(tag.name)"
                vc.tag = tag
            }
        }
    }
    
    // KVO - Used to know when the user goes/leaves fullscreen
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        if keyPath == "bounds" {
            
            guard let oldValue = change?[.oldKey] as? NSValue else {
                return
            }
            
            let oldRect = oldValue.cgRectValue as CGRect
            
            // Moving from fullscreen to smaller size
            if oldRect.size == UIScreen.main.bounds.size {
                guard let mediaContentState = mediaContentState else { return }
                
                if case let .TV(player) = mediaContentState {
                    if player.videoFinished {
                        togglePlaceholder(isHidden: false)
                    }
                }
            }
        }
    }
    
    // Toggles the placehodler/thumbnail view, with an animation
    func togglePlaceholder(isHidden: Bool) {
        let placeholderView = playerContainerView.subviews.filter({ $0 is MediaPlaceholderView }).first
        
        UIView.animate(withDuration: 0.3, animations: {
            placeholderView?.alpha = isHidden ? 0.0 : 1.0
        }, completion: { (done) in
            placeholderView?.isHidden = isHidden
            
        })
    }
    
    // Toggles the full decription text of the programme
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
        activityController.popoverPresentationController?.sourceView = self.shareButton
        activityController.popoverPresentationController?.sourceRect = self.shareButton.frame
        
        activityController.completionWithItemsHandler = { [weak self] activity, success, items, error in
            
            guard success else { return }
            guard error == nil else { return }
            guard let programmeId = self?.programme.id else { return }
            
            // Log share action
            GATracker.trackEventWith(category: "Share", action: programmeId, label: nil, value: nil)
            
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    func stopMediaPlaying() {
        guard let mediaContentState = mediaContentState else { return }
        
        switch mediaContentState {
            
        case .TV(let videoPlayer):
            videoPlayer.avPlayerViewController.player?.pause()
        case .radio(let soundPlayer):
            soundPlayer.player?.pause()
        }
    }
    
    // Remove the KVO observers
    deinit {
        
        if let mediaContentState = mediaContentState {
            switch mediaContentState {
                
            case .TV(let player):
                player.avPlayerViewController.contentOverlayView?.removeObserver(self, forKeyPath: "bounds")
            case .radio(let player):
                player.contentOverlayView?.removeObserver(self, forKeyPath: "bounds")
            }
        }
    }
    
    
    // Expansion state, used to know if the description is expanded or not, or notExpandable i.e the text isn't long enough to be expanded
    enum ExpansionState {
        
        case notExpandable
        case contracted
        case expanded
    }
    
    // The media content currently set, with associated players
    enum MediaContentState {
        
        case TV(PlayerViewController)
        case radio(SoundPlayerViewController)
    }
}


extension Notification.Name {
    
    static let mediaWillPlay = Notification.Name("mediaWillPlay")
}
