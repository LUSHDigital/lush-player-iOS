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
        
        self.navigationController?.isNavigationBarHidden = true
       
        let nib = UINib(nibName: cellReuseId, bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: cellReuseId)
        
        // Set up all spacing for each collection view
        if let channelFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            channelFlowLayout.minimumLineSpacing = 2
            channelFlowLayout.minimumInteritemSpacing = 1
        }
        
        self.collectionView?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowChannelSegue" {
            guard let vc = segue.destination as? ChannelListingContainerViewController else { return }
            
            guard let channel = sender as? Channel else { return }
            vc.childListingViewController?.selectedChannel = channel
            vc.channel = channel
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let channel = LushPlayerController.allChannels[indexPath.item]
        performSegue(withIdentifier: "ShowChannelSegue", sender: channel)
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
