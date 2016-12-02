//
//  Programme.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

struct Programme {
    
    let id: String
    
    var title: String?
    
    var description: String?
    
    var thumbnailURL: URL?
    
    var date: Date?
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let _id = dictionary["id"] as? String else { return nil }
        
        id = _id
        title = dictionary["title"] as? String
        description = dictionary["description"] as? String
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
