//
//  LushPlayerController.swift
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
#if os(iOS)
    import ThunderRequest
#elseif os(tvOS)
    import ThunderRequestTV
#endif

public typealias ProgrammesCompletion = (_ error: Error?, _ programmes: [Programme]?) -> (Void)
public typealias ProgrammeDetailsCompletion = (_ error: Error?, _ programme: Programme?) -> (Void)
public typealias PlaylistCompletion = (_ error: Error?, _ playlistID: String?) -> (Void)
public typealias SearchResultsCompletion = (_ error: Error?, _ searchResults: [Programme]?) -> (Void)
public typealias ChannelCompletion = (_ error: Error?, _ searchResults: [Channel]?) -> (Void)
public typealias EventsCompletion = (_ error: Error?, _ searchResults: [Event]?) -> (Void)



public extension Notification.Name {
    public static let ProgrammesRefreshed: NSNotification.Name = NSNotification.Name(rawValue: "ProgrammesRefreshed")
}

/// A controller which interfaces with lush's player API to return information about TV/Radio programmes and their live playlist
public class LushPlayerController {
    
    /// A shared instance to be used to make requests
    public static let shared = LushPlayerController()
    
    /// Programmes sorted by media type
    public var programmes: [Programme.Media: [Programme]] = [:]
    
    /// Programmes sorted by channel
    public var channelProgrammes: [Channel : [Programme]] = [:]

    /// The request controller used to make requests to the API
    private let requestController = TSCRequestController(baseURL: URL(string: "http://admin.player.lush.com/lushtvapi/v2/"))
    
    /// Fetches all the programmes for a specified media type
    ///
    /// - Parameters:
    ///   - media: The media type to fetch programmes for
    ///   - completion: A block of code to be called once programmes have been fetched
    public func fetchProgrammes(for media: Programme.Media, with completion: @escaping ProgrammesCompletion) {
        
        var endpoint = "videos"
        switch media {
        case .TV:
            endpoint = "videos"
        case .radio:
            endpoint = "radio"
        }
        
        requestController.get("views/\(endpoint)") { [weak self] (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let videos = response?.array as? [[AnyHashable : Any]] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            let programmes = videos.flatMap({ (video) -> Programme? in
                return Programme(dictionary: video, media: media)
            })
            
            self?.programmes[media] = programmes
            NotificationCenter.default.post(name: NSNotification.Name.ProgrammesRefreshed, object: nil, userInfo: ["mediaType": media])
            completion(nil, programmes)
        }
    }
    
    /// Fetches the programmes for a specific LUSH channel
    ///
    /// - Parameters:
    ///   - channel: The channel to fetch programmes for
    ///   - medium: The media type to fetch programmes for
    ///   - completion: A block of code to be called once programmes have been fetched
    public func fetchProgrammes(for channel: Channel, of medium: Programme.Media?, with completion: @escaping ProgrammesCompletion) {
        
        var endpoint = "views/categories?channel=\(channel.tag)"
        if let medium = medium {
            endpoint.append("&type=\(medium.rawValue)")
        }
        
        requestController.get(endpoint) { [weak self] (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let videos = response?.array as? [[AnyHashable : Any]] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            let programmes = videos.flatMap({ (video) -> Programme? in
                
                guard let mediaString = video["type"] as? String, let media = Programme.Media(rawValue: mediaString) else { return nil }
                return Programme(dictionary: video, media: media)
            })
            
            self?.channelProgrammes[channel] = programmes
            completion(nil, programmes)
        }
    }
    
    /// Fetches more detailed information about a specific programme
    ///
    /// This call is needed for example to find out the Brightcove identifier for a programme
    ///
    /// - Parameters:
    ///   - programme: The programme to pull details for
    ///   - completion: A block of code to be called when the programme details are fetched
    public func fetchDetails(for programme: Programme, with completion: @escaping ProgrammeDetailsCompletion) {
        
        requestController.get("views/programme?id=\(programme.id)") { (response, error) in
        
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard var programmeDict = response?.array?.first as? [AnyHashable : Any] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            // To make sure the programme is allocated correctly
            programmeDict["id"] = programme.id
            
            guard let returnedProgramme = Programme(dictionary: programmeDict, media: programme.media) else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            completion(nil, returnedProgramme)
        }
    }
    
    /// Fetches the current playlist information from the API
    ///
    /// - Parameters:
    ///   - utcOffset: The time offset of the current user in minutes from UTC. If not set this value will be calculated
    ///   - completion: A block of code to be called when the playlist has been fetched
    public func fetchLivePlaylist(with utcOffset: Int?, completion: @escaping PlaylistCompletion) {
        
        //let timezoneOffset = utcOffset ?? (TimeZone.current.secondsFromGMT(for: Date()) / 60)
        
        requestController.get("views/playlist") { (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let responseDict = response?.array?.first as? [AnyHashable : Any] else {
                completion(LushPlayerError.emptyResponse, nil)
                return
            }
            
            guard let playlistID = responseDict["id"] as? String else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            completion(nil, playlistID)
        }
    }
    
    /// Searches for programmes based on a user-entered search term
    ///
    /// - Parameters:
    ///   - term: The term to search for programmes under
    ///   - completion: A block of code to be called when the search results have been returned
    public func performSearch(for term: String, with completion: @escaping SearchResultsCompletion) {
        
        let termSpacesRemoved = term.replacingOccurrences(of: " ", with: "+")
        
        let finalTerm = termSpacesRemoved.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? termSpacesRemoved
        requestController.get("programme-search/\(finalTerm)") { (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let videos = response?.array as? [[AnyHashable : Any]] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            let programmes = videos.flatMap({ (video) -> Programme? in
                
                guard let mediaString = video["type"] as? String, let media = Programme.Media(rawValue: mediaString) else { return nil }
                return Programme(dictionary: video, media: media)
            })
            
            completion(nil, programmes)
        }
    }
    
    /// Fetches the programmes for a specific tag
    ///
    /// - Parameters:
    ///   - tag: The tag to fetch programmes for, its value property is used
    ///   - completion: A block of code to be called once programmes have been fetched
    public func fetchProgrammes(for tag: Tag, with completion: @escaping ProgrammesCompletion) {
        
        let endpoint = "tags/\(tag.value)"
        
        requestController.get(endpoint) { (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let videos = response?.array as? [[AnyHashable : Any]] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            let programmes = videos.flatMap({ (video) -> Programme? in
                
                guard let mediaString = video["type"] as? String, let media = Programme.Media(rawValue: mediaString) else { return nil }
                return Programme(dictionary: video, media: media)
            })
            
            completion(nil, programmes)
        }
    }
    
    /// Fetches a list of channels
    /// Channels group media content by a related topic
    ///
    /// - Parameter completion: A block of code to be called once channels have been fetched
    public func fetchChannels(completion: @escaping ChannelCompletion) {
        
        let endpoint = "channels"
        
        requestController.get(endpoint) { (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let channels = response?.array as? [[AnyHashable : Any]] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            let parsedChannels = channels.flatMap({ (channelDictionary) -> Channel? in
                return Channel(with: channelDictionary)
            })
            
            completion(nil, parsedChannels)
        }

    }
    
    /// Fetches a list of Lush events for which there is related media content for
    ///
    /// - Parameter completion: A block of code to be called once events have been fetched
    public func fetchEvents(completion: @escaping EventsCompletion) {
        
        let endpoint = "events"
        
        requestController.get(endpoint) { (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let eventsArray = response?.array as? [[AnyHashable : Any]] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            let events = eventsArray.flatMap({ (eventDict) -> Event? in
                
                return Event(with: eventDict)
            })
            
            completion(nil, events)
        }
    }
    
    /// Fetches a list of media content for a given event
    ///
    /// - Parameters:
    ///   - event: The event
    ///   - completion: A block of code to be called once all the media for an event has been fetched
    public func fetchEventDetail(for event: Event, completion: @escaping ProgrammesCompletion) {
        
        let endpoint = "events/\(event.id)"
        
        requestController.get(endpoint) { (response, error) in
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let videos = response?.array as? [[AnyHashable : Any]] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            let programmes = videos.flatMap({ (video) -> Programme? in
                
                guard let mediaString = video["type"] as? String, let media = Programme.Media(rawValue: mediaString) else { return nil }
                return Programme(dictionary: video, media: media)
            })
            
            completion(nil, programmes)
        }
    }
}


/// Enumeration of possible errors from the PlayerController
///
/// - invalidResponseStatus: The response recieved from the server is not acceptable i.e is 404 when should be 200
/// - invalidResponse: The response recieved from the server cannot be parsed into a useable format
/// - emptyResponse: The response doesn't contain any information
public enum LushPlayerError: Error {
    case invalidResponseStatus
    case invalidResponse
    case emptyResponse
}
