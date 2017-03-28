//
//  Channel.swift
//  LushPlayerKit
//
//  Created by Joel Trew on 20/03/2017.
//
//

import Foundation

public enum Channel : String {
    
    case life = "lushlife"
    case kitchen = "kitchen"
    case times = "times"
    case soapbox = "soapbox"
    case gorilla = "gorilla"
    case cosmetics = "cosmetics"
    
    public func image() -> UIImage? {
        
        switch self {
        case .life:
            return UIImage(named: "Channel-Life")
        default:
            return UIImage(named: "Channel-\(rawValue.capitalized)")
        }
    }
    
    public var title: String {
        
        switch self {
        case .life:
            return "Lush Life"
        case .kitchen:
            return "Lush Kitchen"
        case .times:
            return "Lush Times"
        case .soapbox:
            return "SoapBox"
        case .gorilla:
            return "Gorilla"
        case .cosmetics:
            return "Lush Cosmetics"
        }
    }
}
