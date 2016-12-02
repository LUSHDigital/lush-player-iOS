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
        case TV = "TV"
        case radio = "RADIO"
    }
    
    let id: String
    
    var title: String?
    
    var description: String?
    
    var thumbnailURL: URL?
    
    var date: Date?
    
    let media: Media
    
    init?(dictionary: [AnyHashable : Any], media: Media) {
        
        guard let _id = dictionary["id"] as? String else { return nil }
        
        self.media = media
        id = _id
        
        title = (dictionary["title"] as? String)?.htmlUnescape()
        description = (dictionary["description"] as? String)?.htmlUnescape()
        if let url = dictionary["thumbnail"] as? String {
            thumbnailURL = URL(string: url)
        }
        
        if let dateString = dictionary["date"] as? String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            date = dateFormatter.date(from: dateString)
        }
    }
}
