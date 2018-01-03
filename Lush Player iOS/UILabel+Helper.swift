//
//  UILabel+Helper.swift
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

extension UILabel {
    
    func countLabelLines() -> Int {
        
        self.layoutIfNeeded()
        let textAsNSString = (text ?? "") as NSString
        let attributes = [NSAttributedStringKey.font : font as Any]
        
        let labelSize = textAsNSString.boundingRect(with: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
    
    func isTruncated() -> Bool {
        
        if (countLabelLines() > numberOfLines) {
            return true
        }
        return false
    }
    
    
    func kern(with value: CGFloat) {
        self.attributedText =  NSAttributedString(string: self.text ?? "", attributes: [NSAttributedStringKey.kern: value, NSAttributedStringKey.font: self.font, NSAttributedStringKey.foregroundColor: self.textColor])
    }
}
