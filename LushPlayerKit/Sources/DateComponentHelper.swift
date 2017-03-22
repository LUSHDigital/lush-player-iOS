//
//  DateComponentHelper.swift
//  LushPlayerKit
//
//  Created by Joel Trew on 22/03/2017.
//
//

import Foundation

// A useful extension on DateComponents to return the `TimeInterval` since the start of the day
extension DateComponents {
    
    public var timeIntervalSinceStartOfDay: TimeInterval? {
        get {
            guard let hour = hour, let minute = minute, let second = second else { return nil }
            return (Double(hour) * 3600.0) + (Double(minute) * 60.0) + Double(second)
        }
    }
}
