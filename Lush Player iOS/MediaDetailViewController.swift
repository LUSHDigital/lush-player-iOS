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
    
    var programme: Programme!
    
    @IBOutlet weak var mediaTypeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var expandDescriptionButton: UIButton!
    
    var descriptionExpansion: ExpansionState = .contracted
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        mediaTypeLabel.text = programme.media.displayString()
        
        descriptionLabel.text = programme.description
        
        dateLabel.text = programme.date?.timeAgo
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !descriptionLabel.isTruncated() {
            expandDescriptionButton.isHidden = true
        }
    }
    
    @IBAction func pressedExpandButton(_ sender: Any) {
        
        switch descriptionExpansion {
        case .contracted:
            descriptionLabel.numberOfLines = 0
            descriptionExpansion = .expanded
        
        case .expanded:
            descriptionLabel.numberOfLines = 3
            descriptionExpansion = .contracted
        
        case .notExpandable:
            return
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    
    enum ExpansionState {
        
        case notExpandable
        case contracted
        case expanded
    }
}
