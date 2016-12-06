//
//  LushPlayerController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation
import ThunderRequestTV

typealias ProgrammesCompletion = (_ error: Error?, _ programmes: [Programme]?) -> (Void)
typealias ProgrammeDetailsCompletion = (_ error: Error?, _ programme: Programme?) -> (Void)
typealias PlaylistCompletion = (_ error: Error?, _ playlistID: String?) -> (Void)
typealias SearchResultsCompletion = (_ error: Error?, _ searchResults: [SearchResult]?) -> (Void)

enum Channel : String {
    
    case life = "lushlife"
    case kitchen = "kitchen"
    case times = "times"
    case soapbox = "soapbox"
    case gorilla = "gorilla"
    case cosmetics = "cosmetics"
    
    func image() -> UIImage? {
        
        switch self {
        case .life:
            return UIImage(named: "Channel-Life")
        default:
            return UIImage(named: "Channel-\(rawValue.capitalized)")
        }
    }
}

public extension Notification.Name {
    public static let ProgrammesRefreshed: NSNotification.Name = NSNotification.Name(rawValue: "ProgrammesRefreshed")
}

/// A controller which interfaces with lush's player API to return information about TV/Radio programmes and their live playlist
class LushPlayerController {
    
    /// A shared instance to be used to make requests
    static let shared = LushPlayerController()
    
    /// Programmes sorted by media type
    var programmes: [Programme.Media: [Programme]] = [:]
    
    /// Programmes sorted by channel
    var channelProgrammes: [Channel : [Programme]] = [:]
    
    static var allChannels: [Channel] {
        get {
            return [
                .life,
                .kitchen,
                .times,
                .soapbox,
                .gorilla,
                .cosmetics
            ]
        }
    }
    
    /// The request controller used to make requests to the API
    private let requestController = TSCRequestController(baseURL: URL(string: "http://admin.player.lush.com/lushtvapi/v1/views/"))
    
    /// Fetches all the programmes for a specified media type
    ///
    /// - Parameters:
    ///   - media: The media type to fetch programmes for
    ///   - completion: A block of code to be called once programmes have been fetched
    func fetchProgrammes(for media: Programme.Media, with completion: @escaping ProgrammesCompletion) {
        
        var endpoint = "videos"
        switch media {
        case .TV:
            endpoint = "videos"
        case .radio:
            endpoint = "radio"
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
                return Programme(dictionary: video, media: media)
            })
            
            self?.programmes[media] = programmes
            NotificationCenter.default.post(name: NSNotification.Name.ProgrammesRefreshed, object: nil, userInfo: ["mediaType": media])
            completion(nil, programmes)
        }
    }
    
    func fetchProgrammes(for channel: Channel, of medium: Programme.Media?, with completion: @escaping ProgrammesCompletion) {
        
        var endpoint = "categories?channel=\(channel.rawValue)"
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
    func fetchDetails(for programme: Programme, with completion: @escaping ProgrammeDetailsCompletion) {
        
        requestController.get("programme?id=\(programme.id)") { (response, error) in
        
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
    func fetchLivePlaylist(with utcOffset: Int?, completion: @escaping PlaylistCompletion) {
        
        let timezoneOffset = utcOffset ?? (TimeZone.current.secondsFromGMT(for: Date()) / 60)
        
        requestController.get("playlist?offset=\(timezoneOffset)") { (response, error) in
            
            if let _error = error {
                
                completion(_error, nil)
                return
            }
            
            if response?.status != 200 {
                completion(LushPlayerError.invalidResponseStatus, nil)
                return
            }
            
            guard let responseDict = response?.array?.first as? [AnyHashable : Any] else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            guard let playlistID = responseDict["id"] as? String else {
                completion(LushPlayerError.invalidResponse, nil)
                return
            }
            
            completion(nil, playlistID)
        }
    }
    
    func performSearch(for term: String, with completion: @escaping SearchResultsCompletion) {
        
        requestController.get("search?title=\(term)") { (response, error) in
            
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
            
            let programmes = videos.flatMap({ (video) -> SearchResult? in
                return SearchResult(dictionary: video)
            })
            
            completion(nil, programmes)
        }
    }
}

enum LushPlayerError: Error {
    case invalidResponseStatus
    case invalidResponse
}
