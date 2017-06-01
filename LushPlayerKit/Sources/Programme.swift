//
//  Programme.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

/// An structual representation of a radio or TV programme back from the LUSH API
public struct Programme {
    
    /// An enum representing the media type of the programme
    ///
    /// - TV: The programme is a TV episode
    /// - radio: The programme is a Radio episode
    public enum Media: String {
        case TV = "tv_program"
        case radio = "radio_program"
        
        public func displayString() -> String {
            switch self {
            case .TV:
                return "TV"
            case .radio:
                return "RADIO"
            }
        }
        
        /// Override the default initialiser for raw values. The Home channels use "tv_program" and "radio_program" as their types but the categories endpoint uses "tv" and "radio"
        ///
        /// - Parameter rawValue: The string that defines the type for
        public init?(rawValue: String) {
            switch rawValue {
                case "tv_program": self = .TV
                case "tv": self = .TV
                case "radio_program": self = .radio
                case "radio": self = .radio
                default: return nil
            }
        }
    }
    
    /// A unique ID for the programme
    public let id: String
    
    /// The global unique ID for the programme
    public var guid: String?
    
    /// The title of the programme
    public var title: String?
    
    /// A short description of the programme
    public var description: String?
    
    /// A URL to the thumbnail data for the programme
    public var thumbnailURL: URL?
        
    /// A file which can be used to play the programme
    /// - Note: This should only be present for Radio programmes
    public var file: URL?
    
    /// The date of the programme
    public var date: Date?
    
    /// A string representation of the programme date
    public var dateString: String?
    
    /// A string describing the duration of the programme
    public var duration: String?
    
    /// The media type of the programme
    public let media: Media
    
    /// A slug of the programme title used in the programme's web url, i.e lush-summit-video
    private let alias: String?
    
    /// The shareable web url of the programme http://player.lush.com
    public var webURL: URL? {
        guard let alias = alias else { return nil }
        let url = "http://player.lush.com/\(media.displayString().lowercased())/\(alias)"
        return URL(string: url)
    }
    
    /// The channel of which the programme belongs
    public var channel: Channel?
    
    /// A list of related terms to the programme; they shown underneath the programme on mobile
    public let tags: [Tag]?
    
    /// Initialises a new Programme with a dictionary representation and media type
    ///
    /// - Note: This is an optional initialiser, and will return nil if there was no unique id for the programme,
    /// as it is then un-usable with API calls.
    ///
    /// - Parameter dictionary: A dictionary representation of the programme
    /// - Parameter media: The media type of the programme
    public init?(dictionary: [AnyHashable : Any], media: Media) {
        
        guard let _id = dictionary["id"] as? String else { return nil }
        
        self.media = media
        id = _id
        
        guid = _id
        
        if let fileString = dictionary["file"] as? String {
            file = URL(string: fileString)
        }
        
        alias = dictionary["alias"] as? String
        
        let tagsArray = dictionary["tags"] as? [[String: String]]
        
        tags = tagsArray?.flatMap({ (tagDictionary) -> Tag? in
            
            guard let tagName = tagDictionary["name"], let tagValue = tagDictionary["tag"] else { return nil }
            
            return Tag(name: tagName, value: tagValue)
        })
        
        let channelString = dictionary["channel"] as? String
        channel = channelString.flatMap({ Channel(rawValue: $0) })
        
        if file == nil, let urlString = dictionary["url"] as? String {
            file = URL(string: urlString)
        }
        
        title = (dictionary["title"] as? String)?.htmlUnescape()
        description = (dictionary["description"] as? String)?.htmlUnescape().trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = dictionary["thumbnail"] as? String {
            thumbnailURL = URL(string: url)
        }
        
        duration = dictionary["duration"] as? String
        
        dateString = dictionary["date"] as? String
        if let dateString = dateString {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            date = dateFormatter.date(from: dateString)
        }
    }
}
