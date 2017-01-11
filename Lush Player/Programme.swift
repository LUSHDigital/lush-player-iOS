//
//  Programme.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

struct Programme {
    
    enum Media: String {
        case TV = "tv_program"
        case radio = "radio_program"
        
        func displayString() -> String {
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
        init?(rawValue: String) {
            switch rawValue {
                case "tv_program": self = .TV
                case "tv": self = .TV
                case "radio_program": self = .radio
                case "radio": self = .radio
                default: return nil
            }
        }
    }
    
    let id: String
    
    var guid: String?
    
    var title: String?
    
    var description: String?
    
    var thumbnailURL: URL?
        
    var file: URL?
    
    var date: Date?
    
    var dateString: String?
    
    var duration: String?
    
    let media: Media
    
    init?(dictionary: [AnyHashable : Any], media: Media) {
        
        guard let _id = dictionary["id"] as? String else { return nil }
        
        self.media = media
        id = _id
        
        guid = dictionary["guid"] as? String
        
        if let fileString = dictionary["file"] as? String {
            file = URL(string: fileString)
        }
        
        if file == nil, let urlString = dictionary["url"] as? String {
            file = URL(string: urlString)
        }
        
        title = (dictionary["title"] as? String)?.htmlUnescape()
        description = (dictionary["description"] as? String)?.htmlUnescape()
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
