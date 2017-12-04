//
//  Channel.swift
//  LushPlayerKit
//
//  Created by Joel Trew on 20/03/2017.
//
//

import Foundation

// Model describing a LUSH Channel which categorizes various programes, i.e Cosmetics
public struct Channel {
    
    // Unique string id for the channel
    public var tag: String
    
    // The display title for the channel
    public var title: String
    
    // The url of the image representing the channel
    public var imageUrl: URL?
}

// Extends Channel to be Equatable, and Hashable for use as a dictionary key
extension Channel: Equatable, Hashable {
    
    public static func ==(lhs: Channel, rhs: Channel) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    public var hashValue: Int {
        return tag.hashValue
    }
}

public extension Channel {
    
    // Initialises a channel from a dictionary object
    public init?(with dictionary: [AnyHashable: Any]) {
        
        guard let tag = dictionary["tag"] as? String else { return nil }
        guard let title = dictionary["name"] as? String else { return nil }
        guard let imageUrlString = dictionary["image"] as? String else { return nil }
        let url = URL(string: imageUrlString)
        
        self.tag = tag
        self.title = title
        self.imageUrl = url
    }
}
