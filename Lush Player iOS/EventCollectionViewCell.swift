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
    
    var pageMode: PagingMode = .page
    
    var didTapViewMore: ((SpacedCharacterButton) -> ())?

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
    
    @IBAction func pressedViewMoreButton(_ sender: SpacedCharacterButton) {
        didTapViewMore?(sender)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        
        
        if case let .individual(number) = pageMode {
            self.pageControl.numberOfPages = number
        } else {
            self.pageControl.numberOfPages = Int(ceil(eventItemsCollectionView.contentSize.width / eventItemsCollectionView.frame.size.width))
        }
        
    }

    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        eventItemsCollectionView.delegate = dataSourceDelegate
        eventItemsCollectionView.dataSource = dataSourceDelegate
        eventItemsCollectionView.tag = row
        eventItemsCollectionView.reloadData()
    }
    
    enum PagingMode {
        case individual(Int)
        case page
    }
}
