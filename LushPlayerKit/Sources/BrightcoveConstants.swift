//
//  BrightcoveConstants.swift
//  Lush Player
//
//  Created by Simon Mitchell on 06/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

/// Constants for use with the Brightcove SDK
public struct BrightcoveConstants {
    
    /// The brightcove account ID
    public static let accountID = "4926724644001"
    
    /// The brightcove policy ID for on-demand content
    public static let onDemandPolicyID = Bundle.main.infoDictionary?["BrightcoveLivePolicyID"] as? String ?? ""
    
    /// The brightcove policy ID for live content
    public static let livePolicyID = Bundle.main.infoDictionary?["BrightcoveOnDemandPolicyID"] as? String ?? ""
}
