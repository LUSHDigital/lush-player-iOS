//
//  BrightcoveConstants.swift
//  Lush Player
//
//  Created by Simon Mitchell on 06/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

/// Constants for use with the Brightcove SDK
struct BrightcoveConstants {
    
    /// The brightcove account ID
    static let accountID = "4926724644001"
    
    /// The brightcove policy ID for on-demand content
    static let onDemandPolicyID = Bundle.main.infoDictionary?["BrightcoveLivePolicyID"] as? String ?? ""
    
    /// The brightcove policy ID for live content
    static let livePolicyID = Bundle.main.infoDictionary?["BrightcoveOnDemandPolicyID"] as? String ?? ""
}
