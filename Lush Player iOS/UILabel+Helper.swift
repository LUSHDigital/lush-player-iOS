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
    
    func isTruncated() -> Bool {
        
        guard let text = self.text else { return false }
        
        let textString = text as NSString
        
        let boundingSize = CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let size = textString.boundingRect(with: boundingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font], context: nil).size
        
        return size.height > self.bounds.size.height
    }
    
}
