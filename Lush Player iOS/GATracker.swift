//
//  Tracker.swift
//  SAF
//
//  Created by Matthew Cheetham on 27/07/2016.
//  Copyright © 2016 3 SIDED CUBE. All rights reserved.
//

import Foundation

/**
 Provides Google Analytics tracking functionality to the app. All tracking should be done via this file
 */
class GATracker {
    
    /**
     Logs a page view with GA
     - param named: The page name to track
     */
    class func trackPage(named: String) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        guard let _tracker = tracker else {
            return
        }
        
        _tracker.set(kGAIScreenName, value: named)
        
        if let builder = GAIDictionaryBuilder.createScreenView() {
            _tracker.send(builder.build() as [NSObject : AnyObject])
        }
        
    }
    
    /**
     Logs an event into Google Analytics
     - param category: The GA Category to file under
     - param action: A description of the action taken by the user
     - param label: Additional description of the event action if applicable
     - param value: A numerical value to add to the event if applicable
     */
    class func trackEventWith(category: String, action: String, label: String?, value: NSNumber?) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        guard let _tracker = tracker else {
            return
        }
        
        if let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value) {
            _tracker.send(builder.build() as [NSObject : AnyObject])
        }
        
    }
}
