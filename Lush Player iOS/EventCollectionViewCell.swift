//
//  EventCollectionViewCell.swift
//  Lush Player
//
//  Created by Joel Trew on 10/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eventLabel: UILabel!
    
    @IBOutlet weak var eventItemsCollectionView: EventCollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var button: SpacedCharacterButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let nib = UINib(nibName: "StandardMediaCell", bundle: nil)
        eventItemsCollectionView.register(nib, forCellWithReuseIdentifier: "StandardMediaCellId")
        
        if let text = button.titleLabel?.text {
            let uppercased = text.uppercased()
            button.setTitle(uppercased, for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        eventItemsCollectionView.delegate = dataSourceDelegate
        eventItemsCollectionView.dataSource = dataSourceDelegate
        eventItemsCollectionView.tag = row
        eventItemsCollectionView.reloadData()
    }
}
