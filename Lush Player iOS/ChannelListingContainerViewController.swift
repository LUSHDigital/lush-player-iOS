//
//  ChannelListingContainerViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 27/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

// The containg listing view controller for channel programmes, includes a menu for filtering the itemsn
class ChannelListingContainerViewController: MenuContainerViewController {
    
    // Channel model
    var channel: Channel!
    
    // The listing controller displaying the programmes
    var childListingViewController: ChannelListingViewController? {
        return childViewControllers.filter({ $0 is ChannelListingViewController}).first as? ChannelListingViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up menu items - All, TV and Radio
        menuItems = [
        MenuItem(title: "All Episodes", identifier: "all"),
        MenuItem(title: Programme.Media.TV.displayString(), identifier: Programme.Media.TV.rawValue),
        MenuItem(title: Programme.Media.radio.displayString(), identifier: Programme.Media.radio.rawValue)
        ]
        
        title = channel.title
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ChannelListingViewControllerId") as? ChannelListingViewController else { return }
        viewController.selectedChannel = channel
        
        addChildViewController(viewController)
        containerView.addSubview(viewController.view)
        didMove(toParentViewController: viewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        
        let firstIndex = IndexPath(item: 0, section: 0)
        menuCollectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .left)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let menuItem = menuItems[indexPath.item]
        
        // Filter programmes based on the menu item 
        if let programmes = LushPlayerController.shared.channelProgrammes[channel] {
            
            let filteredProgrammes = programmes.filter({ (programme) -> Bool in
                
                if menuItem.identifier == "all" { return true }
                return programme.media.rawValue == menuItem.identifier
            })
            
            if filteredProgrammes.isEmpty {
                
                childListingViewController?.viewState = .empty
                
                guard let emptyStateViewController = childListingViewController?.emptyStateViewController as? EmptyErrorViewController else { return }
                emptyStateViewController.descriptionLabel.text = "Sorry, no \(menuItem.identifier == "all" ? "" : menuItem.title) episodes here right now"
                
                if let url = channel.imageUrl {
                    if let image = ImageCacher.retrieveImage(at: url.lastPathComponent) {
                        emptyStateViewController.channelImageView.image = image
                    } else {
                        emptyStateViewController.channelImageView.set(imageURL: channel.imageUrl, withPlaceholder: nil, completion: nil)
                    }
                }
                
                return
            }
            
            if let media = Programme.Media(rawValue: menuItem.identifier) {
                GATracker.trackPage(named: "\(media.displayString()) listing")
            }
            
            childListingViewController?.viewState = .loaded(filteredProgrammes)
        } 
    }
}
