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

public extension Notification.Name {
    public static let ProgrammesRefreshed: NSNotification.Name = NSNotification.Name(rawValue: "ProgrammesRefreshed")
}

class LushPlayerController {
    
    static let shared = LushPlayerController()
    
    var programmes: [Programme.Media: [Programme]] = [:]
    
    private let requestController = TSCRequestController(baseURL: URL(string: "http://admin.player.lush.com/lushtvapi/v1/views/"))
    
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
}

enum LushPlayerError: Error {
    case invalidResponseStatus
    case invalidResponse
}
