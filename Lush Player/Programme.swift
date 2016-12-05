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
    }
    
    let id: String
    
    var guid: String?
    
    var title: String?
    
    var description: String?
    
    var thumbnailURL: URL?
    
    var url: URL?
    
    var file: URL?
    
    var date: Date?
    
    var duration: String?
    
    let media: Media
    
    init?(dictionary: [AnyHashable : Any], media: Media) {
        
        guard let _id = dictionary["id"] as? String else { return nil }
        
        self.media = media
        id = _id
        
        guid = dictionary["guid"] as? String
        if let urlString = dictionary["url"] as? String {
            url = URL(string: urlString)
        }
        
        if let fileString = dictionary["file"] as? String {
            file = URL(string: fileString)
        }
        
        title = (dictionary["title"] as? String)?.htmlUnescape()
        description = (dictionary["description"] as? String)?.htmlUnescape()
        if let url = dictionary["thumbnail"] as? String {
            thumbnailURL = URL(string: url)
        }
        
        duration = dictionary["duration"] as? String
        
        if let dateString = dictionary["date"] as? String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            date = dateFormatter.date(from: dateString)
        }
    }
}
