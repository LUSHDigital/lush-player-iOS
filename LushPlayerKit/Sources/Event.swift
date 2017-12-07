//
//  Event.swift
//  LushPlayerKit
//
/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

import Foundation

public struct Event {
    
    public var id: String
    public var title: String
    public var programmes: [Programme]
    public var startDate: Date
    public var endDate: Date
    
    // returns a new event object with a new array of programmes
    public func addProgrammes(_ programmes: [Programme]) -> Event {
        let event = Event(id: self.id, title: self.title, programmes: programmes, startDate: self.startDate, endDate: self.endDate)
        return event
    }
}

public extension Event {
    public init?(with dictionary: [AnyHashable: Any]) {
        
        guard let id = dictionary["tag"] as? String else { return nil }
        guard let title = dictionary["name"] as? String else { return nil }
        guard let startDateString = dictionary["start_date"] as? String else { return nil }
        guard let endDateString = dictionary["end_date"] as? String else { return nil }
        
        
        self.id = id
        self.title = title
        
        let formatter = DateFormatter()
        
        
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        guard let startDate = formatter.date(from: startDateString) else {
            return nil
        }
        
        guard let endDate = formatter.date(from: endDateString) else {
            return nil
        }
        
        self.startDate = startDate
        self.endDate = endDate
        self.programmes = []
    }
}
