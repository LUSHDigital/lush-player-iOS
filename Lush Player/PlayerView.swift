//
//  PlayerView.swift
//  Lush Player
//
//  Created by Simon Mitchell on 08/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    var playerLayer: AVPlayerLayer? {
        get {
            return layer as? AVPlayerLayer
        }
    }

    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
}
