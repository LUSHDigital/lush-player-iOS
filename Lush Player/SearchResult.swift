//
//  SearchResult.swift
//  Lush Player
//
//  Created by Simon Mitchell on 05/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

struct SearchResult {
    
    enum Media: String {
        case TV = "tv"
        case radio = "radio"
        
        func displayString() -> String {
            switch self {
            case .TV:
                return "TV"
            case .radio:
                return "RADIO"
            }
        }
    }
    
    let id: String
    
    var title: String?
    
    var thumbnailURL: URL?
    
    let media: Media
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let _id = dictionary["id"] as? String, let mediaString = dictionary["type"] as? String, let media = Media(rawValue: mediaString) else { return nil }
        
        self.media = media
        id = _id
        
        title = (dictionary["title"] as? String)?.htmlUnescape()
        if let videoThumbnailUrl = dictionary["video_thumbnail"] as? String {
            thumbnailURL = URL(string: videoThumbnailUrl)
        }
        
        if thumbnailURL == nil, let radioThumbnailUrl = dictionary["radio_thumbnail"] as? String {
            thumbnailURL = URL(string: radioThumbnailUrl)
        }
    }
}

