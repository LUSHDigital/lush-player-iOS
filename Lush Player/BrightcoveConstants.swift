//
//  BrightcoveConstants.swift
//  Lush Player
//
//  Created by Simon Mitchell on 06/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

struct BrightcoveConstants {
    
    static let accountID = "4926724644001"
    
    static let onDemandPolicyID = Bundle.main.infoDictionary?["BrightcoveLivePolicyID"] as? String ?? ""
    
    static let livePolicyID = Bundle.main.infoDictionary?["BrightcoveOnDemandPolicyID"] as? String ?? ""
}
