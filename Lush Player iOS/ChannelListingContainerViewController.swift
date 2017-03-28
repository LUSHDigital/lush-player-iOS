//
//  ChannelListingContainerViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 27/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class ChannelListingContainerViewController: MenuContainerViewController {
    
    var channel: Channel!
    
    var childListingViewController: ChannelListingViewController? {
        return childViewControllers.filter({ $0 is ChannelListingViewController}).first as? ChannelListingViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        
        let firstIndex = IndexPath(item: 0, section: 0)
        menuCollectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .left)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let menuItem = menuItems[indexPath.item]
        let programmes = filterProgrammes(filterTerm: menuItem.identifier)
        childListingViewController?.viewState = .loaded(programmes)
        
    }
    
    func filterProgrammes(filterTerm: String) -> [Programme] {
        
        switch filterTerm {
        case Programme.Media.radio.rawValue:
            return LushPlayerController.shared.channelProgrammes[channel]?.filter({ $0.media == Programme.Media.radio }) ?? []
        case Programme.Media.TV.rawValue:
            return LushPlayerController.shared.channelProgrammes[channel]?.filter({ $0.media == Programme.Media.TV }) ?? []
        default:
            return LushPlayerController.shared.channelProgrammes[channel] ?? []
        }
 
    }
}
