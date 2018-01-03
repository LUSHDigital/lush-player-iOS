//
//  Channel.swift
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

// Model describing a LUSH Channel which categorizes various programes, i.e Cosmetics
public struct Channel {
    
    // Unique string id for the channel
    public var tag: String
    
    // The display title for the channel
    public var title: String
    
    // The url of the image representing the channel
    public var imageUrl: URL?
}

// Extends Channel to be Equatable, and Hashable for use as a dictionary key
extension Channel: Equatable, Hashable {
    
    public static func ==(lhs: Channel, rhs: Channel) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    public var hashValue: Int {
        return tag.hashValue
    }
}

public extension Channel {
    
    // Initialises a channel from a dictionary object
    public init?(with dictionary: [AnyHashable: Any]) {
        
        guard let tag = dictionary["tag"] as? String else { return nil }
        guard let title = dictionary["name"] as? String else { return nil }
        guard let imageUrlString = dictionary["image"] as? String else { return nil }
        let url = URL(string: imageUrlString)
        
        self.tag = tag
        self.title = title
        self.imageUrl = url
    }
}
