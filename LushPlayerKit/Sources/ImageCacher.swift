//
//  ImageCacher.swift
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
import UIKit

/// Image cacheing utility so avoid unnecessary network requests
public class ImageCacher {
    
    /// The location of the system defined temp directory for storing non critical info which can be cleared if the user needs space
    static var temporaryDirectory: URL {
        if #available(iOSApplicationExtension 10.0, *) {
            return FileManager.default.temporaryDirectory
        } else {
            return URL(fileURLWithPath: (NSTemporaryDirectory() as String))
        }
    }

    /// Caches an image to disk using a name
    ///
    /// - Parameters:
    ///   - image: Image to cache
    ///   - name: The name the file should be saved under
    public static func cache(_ image: UIImage, with name: String) {
    
        let url = temporaryDirectory.appendingPathComponent(name)
    
        DispatchQueue.global().async {
            let representation = UIImagePNGRepresentation(image)
            try? representation?.write(to: url)
        }
    }
    
    /// Retrieves an iamge from teh cache if it exists
    ///
    /// - Parameter filePath: The name of the file to retrieve
    /// - Returns: An optional image, nil if not found on disk
    public static func retrieveImage(at fileName: String) -> UIImage? {
        
        let url = ImageCacher.temporaryDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: url, options: []) else { return nil }

        let image = UIImage(data: data)
        return image
    }
}
