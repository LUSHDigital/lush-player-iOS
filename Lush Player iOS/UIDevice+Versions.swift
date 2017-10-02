//
//  UIDevice+Versions.swift
//  LUSH
//
//  Created by Daniela on 11/4/14.
//  Copyright (c) 2014 Lush. All rights reserved.
//

import UIKit

extension UIDevice {
    
    class func displayType() -> DisplayType {
        return Display.displayType
    }
}

// Based on https://gist.github.com/hfossli/bc93d924649de881ee2882457f14e346
//
public enum DisplayType {
    case unknown
    case iphone4
    case iphone5
    case iphone6and7
    case iphone6and7plus
	case iphoneX
}

private final class Display {
    class var width:CGFloat { return UIScreen.main.bounds.size.width }
    
    class var height:CGFloat { return UIScreen.main.bounds.size.height }
    
    class var maxLength:CGFloat { return max(width, height) }
    
    class var minLength:CGFloat { return min(width, height) }
    
    class var zoomed:Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    
    class var retina:Bool { return UIScreen.main.scale >= 2.0 }
    
    class var phone:Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    
    class var pad:Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    
    @available(iOS 9.0, *)
    class var carplay:Bool { return UIDevice.current.userInterfaceIdiom == .carPlay }
    
    @available(iOS 9.0, *)
    class var tv:Bool { return UIDevice.current.userInterfaceIdiom == .tv }
    
    class var displayType: DisplayType {
				
        if phone && maxLength < 568 {
            return .iphone4
        }
        else if phone && maxLength == 568 {
            return .iphone5
        }
        else if phone && maxLength == 667 {
            return .iphone6and7
        }
        else if phone && maxLength == 736 {
            return .iphone6and7plus
        }
		else if phone && maxLength == 812 {
			return .iphoneX
		}
        return .unknown
    }
}
