//
//  SpacedCharacterButton.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class SpacedCharacterButton: UIButton {
    
    var spacingAmount: Float = 1.5

    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        let attributedString = NSMutableAttributedString(string: title!, attributes: [NSKernAttributeName : CGFloat(spacingAmount)])
        setAttributedTitle(attributedString, for: .normal)
    }
}
