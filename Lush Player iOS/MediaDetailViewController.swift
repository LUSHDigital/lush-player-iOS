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
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    @IBOutlet weak var mediaPlayerView: UIView!
    
    @IBOutlet weak var mediaTypeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var shareButton: SpacedCharacterButton!
    
    @IBOutlet weak var expandDescriptionButton: UIButton!
    
    var descriptionExpansion: ExpansionState = .contracted
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mediaTypeLabel.text = programme.media.displayString()
        descriptionLabel.text = programme.description
        dateLabel.text = programme.date?.timeAgo
        
        shareButton.setTitle("SHARE", for: .normal)
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Don't show expand button if our text is truncated 
        if descriptionExpansion != .expanded {
            if !descriptionLabel.isTruncated() {
                descriptionExpansion = .notExpandable
                expandDescriptionButton.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = false
        }
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
        
        guard let url = programme.file else { return }
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    // Expansion state, used to know if the description is expanded or not, or notExpandable i.e the text isn't long enough to be expanded
    enum ExpansionState {
        
        case notExpandable
        case contracted
        case expanded
    }
}
