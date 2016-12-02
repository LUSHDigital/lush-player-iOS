//
//  TimeAgo.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

extension Date {
    
    /// Returns a string representation of the time since this date
    var timeAgo: String {
    
        var timeDifference = timeIntervalSince(Date())
        
        if timeDifference < 0 {
            
            timeDifference = abs(timeDifference)
            
            if timeDifference < 60 {
                return "\(Int(timeDifference))s Ago"
            } else if timeDifference < 3600 {
                return "\(Int(timeDifference/60))m Ago"
            } else if timeDifference < 3600 * 24 {
                return "\(Int(timeDifference/3600))h Ago"
            } else if timeDifference < (3600 * 24 * 7) {
                return "\(Int(timeDifference/(3600 * 24))) days ago"
            }
        }
        
        return ""
    }
}
