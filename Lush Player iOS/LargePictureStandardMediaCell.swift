//
//  LargePictureStandardMediaCell.swift
//  Lush Player
//
//  Created by Joel Trew on 25/05/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

// Newer large card style cells for the home page
class LargePictureStandardMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var channelLabel: UILabel!

    @IBOutlet weak var mediaTitleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mediaTypeIconImageView: UIImageView!
    
    var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        shadowView = UIView()
        shadowView.frame = imageView.bounds
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        imageView.insertSubview(shadowView, belowSubview: channelLabel)
        
        
        imageView.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
            shadowView.frame = imageView.bounds
    }
    
    func setMediaTypeImage(type: Programme.Media) {
        
        switch type {
        case .radio:
            mediaTypeIconImageView.image = #imageLiteral(resourceName: "home_radio_icon")
        case .TV:
            mediaTypeIconImageView.image = #imageLiteral(resourceName: "home_video_icon")
        }
    }
    
    override func prepareForReuse() {
        
        imageView.image = nil
        channelLabel.text = nil
        mediaTitleLabel.text = nil
    }
}
