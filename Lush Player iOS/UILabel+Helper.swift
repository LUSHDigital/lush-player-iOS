//
//  UILabel+Helper.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func countLabelLines() -> Int {
        
        self.layoutIfNeeded()
        let textAsNSString = (text ?? "") as NSString
        let attributes = [NSFontAttributeName : font as Any]
        
        let labelSize = textAsNSString.boundingRect(with: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
    
    func isTruncated() -> Bool {
        
        if (countLabelLines() > numberOfLines) {
            return true
        }
        return false
    }
    
    
    func kern(with value: CGFloat) {
        self.attributedText =  NSAttributedString(string: self.text ?? "", attributes: [NSKernAttributeName: value, NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor])
    }
}
