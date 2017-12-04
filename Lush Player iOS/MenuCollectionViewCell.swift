//
//  MenuCollectionViewCell.swift
//  Lush Player
//
//  Created by Joel Trew on 28/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Cell to display a menu option in the container view
class MenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.backgroundColor = UIColor(colorLiteralRed: 91/225, green: 91/225, blue: 91/225, alpha: 1)
            } else {
                self.backgroundColor = UIColor(colorLiteralRed: 51/225, green: 51/225, blue: 51/225, alpha: 1)
            }
        }
    }
}
