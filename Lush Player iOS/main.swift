//
//  main.swift
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
import UIKit

// Hack to stop generic view controllers from crashing when used with objective c storyboards
// TODO: - Find better solution
print(HomeCollectionViewController.self, ChannelListingViewController.self, SearchResultsViewController.self, EventViewController.self, EventListingViewController.self, TagListViewController.self)

// The following is required because there's an impedence mismatch between
// `CommandLine` and `UIApplicationMain` <rdar://problem/25693546>.
let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
    to: UnsafeMutablePointer<Int8>.self,
    capacity: Int(CommandLine.argc)
)
UIApplicationMain(CommandLine.argc, argv, nil, NSStringFromClass(AppDelegate.self))
