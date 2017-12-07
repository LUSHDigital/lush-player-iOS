//
//  SearchResult.swift
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

/// A structural representation of a search result back from the LUSH API
public struct SearchResult {
    
    /// An enum representing the media type of the search result
    ///
    /// - TV: The result is a TV episode
    /// - radio: The result is a Radio episode
    public enum Media: String {
        case TV = "tv"
        case radio = "radio"
        
        public func displayString() -> String {
            switch self {
            case .TV:
                return "TV"
            case .radio:
                return "RADIO"
            }
        }
    }
    
    /// A unique id for the search result
    public let id: String
    
    /// The title of the search result
    public var title: String?
    
    /// A URL to the thumbnail data for the result
    public var thumbnailURL: URL?
    
    /// The media type of the search result
    public let media: Media
    
    /// Initialises a new Programme with a dictionary representation and media type
    ///
    /// - Note: This is an optional initialiser, and will return nil if there was no unique id or media
    /// type for the result, as it is then un-usable with API calls.
    ///
    /// - Parameter dictionary: A dictionary representation of the programme
    public init?(dictionary: [AnyHashable : Any]) {
        
        guard let _id = dictionary["id"] as? String, let mediaString = dictionary["type"] as? String, let media = Media(rawValue: mediaString) else { return nil }
        
        self.media = media
        id = _id
        
        title = (dictionary["title"] as? String)?.htmlUnescape()
        if let videoThumbnailUrl = dictionary["video_thumbnail"] as? String {
            thumbnailURL = URL(string: videoThumbnailUrl)
        }
        
        if thumbnailURL == nil, let radioThumbnailUrl = dictionary["radio_thumbnail"] as? String {
            thumbnailURL = URL(string: radioThumbnailUrl)
        }
    }
}

