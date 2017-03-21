//
//  ChannelCollectionViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 20/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit


class ChannelCollectionViewController: UICollectionViewController {

    private let cellReuseId = String(describing: ChannelCollectionViewCell.self)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
       
        let nib = UINib(nibName: cellReuseId, bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: cellReuseId)
        
        // Set up all spacing for each collection view
        if let channelFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            channelFlowLayout.minimumLineSpacing = 2
            channelFlowLayout.minimumInteritemSpacing = 1
        }
        
        self.collectionView?.delegate = self
        
        
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LushPlayerController.allChannels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as? ChannelCollectionViewCell {
            
            // Set the cell's image to the channel's image
            let channel = LushPlayerController.allChannels[indexPath.item]
            cell.imageView.image = channel.image()
            
            return cell
        }
        
        
        return UICollectionViewCell()
    }

}



extension ChannelCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width / 2 - 1
        let cellHeight = collectionView.bounds.height / 3 - 2
        
        let cellSize = CGSize(width: cellWidth, height: cellHeight)
        return cellSize
    }
}
