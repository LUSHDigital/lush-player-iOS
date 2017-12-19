//
//  BrightcoveHelpers.swift
//  Lush Player
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

extension BCOVPlaylist {
    
    /// Returns the playlist schedule relative to a particular date, by changing up the live playlist data
    /// as if the playlist was running today (If it isn't already)
    ///
    /// - Parameter toDate: The date to return the playlist schedule relative to
    /// - Returns: An array of brightcove video objects, with their start and end date relative to `toDate`
    public func schedule(relative toDate: Date = Date()) -> [(video: BCOVVideo, startDate: Date, endDate: Date)] {
        
        return videos.flatMap({ (video) -> (video: BCOVVideo, startDate: Date, endDate: Date)? in
            
            guard let _video = video as? BCOVVideo else { return nil }
            
            guard let customInfo = _video.properties["custom_fields"] as? [AnyHashable : Any] else { return nil }
            
            guard let startTime = customInfo["starttime"] as? String else { return nil }
            
            // Set up date formatters
			
            let startFormatter = DateFormatter()
            startFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            // Create duration date object and start date object from date formatters
            guard let startDate = startFormatter.date(from: startTime) else {
				return nil
			}
            
            let durationAddition: TimeInterval
            
            if let liveDuration = customInfo["livebroadcastlength"] as? String {
                
                let durationComponentsString = liveDuration.components(separatedBy: ":")
                
                if durationComponentsString.count != 3 {
                    print("Duraction Component is the wrong format: \(liveDuration)")
                    return nil
                }
    
                var seconds: Double = (Double(durationComponentsString[0]) ?? 0) * 60.0 * 60.0
                seconds += (Double(durationComponentsString[1]) ?? 0.0) * 60.0
                seconds += Double(durationComponentsString[2]) ?? 0.0
                
                durationAddition = TimeInterval(seconds)
                
            } else if let durationProperty =  _video.properties["duration"] as? Int {
                durationAddition = TimeInterval(durationProperty)
            } else {
                return nil
            }


			let durationDate = startDate.addingTimeInterval(TimeInterval(durationAddition))
            let components: Set<Calendar.Component> = [.minute, .hour, .second]
			
            // The date components of the date to return relative start/end dates from
            let relativeComponents = Calendar.current.dateComponents([.minute, .hour, .second, .day, .month, .year], from: toDate)
            
            // Change start date back from API so it retains it's time, but takes the day/year/month from our relative date
            var startComponents = Calendar.current.dateComponents(components, from: startDate)
            startComponents.year = relativeComponents.year
            startComponents.month = relativeComponents.month
            startComponents.day = relativeComponents.day
            
            let durationComponents = Calendar.current.dateComponents(components, from: durationDate)
            
            guard let relativeStartDate = Calendar.current.date(from: startComponents) else { return nil }
            
            // Get the time interval through the day from durationComponents, the current time as a date using the same normalisation as for startTimeDate
            guard let interval = durationComponents.timeIntervalSinceStartOfDay else { return nil }
            
            // Calculate the end date of the video
            let endDate = relativeStartDate.addingTimeInterval(interval)
            return (_video, relativeStartDate, endDate)
        })
    }
    
    /// A helper variable which returns the current playlist item from the playlist, and the offset at which
    /// the item should be played to be considered 'live'
    public var playlistPosition: (scheduleItem: (video: BCOVVideo, startDate: Date, endDate: Date), playbackStartTime: TimeInterval)? {
        get {
            
            // First make sure our videos array are actually BCOVVideo objects
            
            var playbackStartTime: TimeInterval = 0
            let currentDate = Date()
            let scheduleArray = schedule(relative: currentDate)
            
            guard let currentVideo = scheduleArray.first(where: { (schedule) -> Bool in
                
                // Return whether the current date falls during the time of the show
                if currentDate >= schedule.startDate && currentDate < schedule.endDate {
                    playbackStartTime = currentDate.timeIntervalSince(schedule.startDate)
                    return true
                } else {
                    return false
                }
            }) else { return nil }
            
            return (currentVideo, playbackStartTime)
        }
    }
}
