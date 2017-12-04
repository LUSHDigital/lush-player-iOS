//
//  UIImage+ColourBlock.swift
//  Lush Player
//
//  Created by Joel Trew on 03/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    class func createImage(with colour: UIColor, size: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        colour.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
