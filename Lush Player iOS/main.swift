//
//  main.swift
//  Lush Player
//
//  Created by Joel Trew on 04/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import Foundation
import UIKit

print(HomeCollectionViewController.self, ChannelListingViewController.self, SearchResultsViewController.self, EventViewController.self, EventListingViewController.self)

// The following is required because there's an impedence mismatch between
// `CommandLine` and `UIApplicationMain` <rdar://problem/25693546>.
let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
    to: UnsafeMutablePointer<Int8>.self,
    capacity: Int(CommandLine.argc)
)
UIApplicationMain(CommandLine.argc, argv, nil, NSStringFromClass(AppDelegate.self))
