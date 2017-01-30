//
//  SearchResult.swift
//  Lush Player
//
//  Created by Simon Mitchell on 05/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

/// A structural representation of a search result back from the LUSH API
struct SearchResult {
    
    /// An enum representing the media type of the search result
    ///
    /// - TV: The result is a TV episode
    /// - radio: The result is a Radio episode
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
    
    /// A unique id for the search result
    let id: String
    
    /// The title of the search result
    var title: String?
    
    /// A URL to the thumbnail data for the result
    var thumbnailURL: URL?
    
    /// The media type of the search result
    let media: Media
    
    /// Initialises a new Programme with a dictionary representation and media type
    ///
    /// - Note: This is an optional initialiser, and will return nil if there was no unique id or media
    /// type for the result, as it is then un-usable with API calls.
    ///
    /// - Parameter dictionary: A dictionary representation of the programme
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

