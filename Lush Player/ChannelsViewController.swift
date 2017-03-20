//
//  ChannelsViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit


/// View controller for displaying content based on the specified LUSH channel.
class ChannelsViewController: RefreshableViewController {
    
    /// The collection view for selecting and displaying the LUSH channels
    @IBOutlet weak var channelSelectionCollectionView: UICollectionView!
    
    /// The collection view for displaying a channel's TV programmes
    @IBOutlet weak var tvProgrammesCollectionView: UICollectionView!
    
    /// The collection view for displaying a channel's Radio programmes
    @IBOutlet weak var radioProgrammesCollectionView: UICollectionView!
    
    /// The channel which was selected by the user, by default being Channel.life
    var selectedChannel: Channel = .life
    
    /// The radio programmes for the selected channel
    var radioProgrammes: [Programme]?
    
    /// The TV programmes for the selected channel
    var tvProgrammes: [Programme]?

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Register the channel collection view cell with it's collection view
        let nib = UINib(nibName: "ChannelCollectionViewCell", bundle: nil)
        channelSelectionCollectionView.register(nib, forCellWithReuseIdentifier: "ChannelCell")
        
        // Register the program cell with both the TV programmes and radio programmes collection views
        let programmeNib = UINib(nibName: "ChannelProgrammeCollectionViewCell", bundle: nil)
        tvProgrammesCollectionView.register(programmeNib, forCellWithReuseIdentifier: "ProgrammeCell")
        tvProgrammesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 92, bottom: 0, right: 92)
        
        radioProgrammesCollectionView.register(programmeNib, forCellWithReuseIdentifier: "ProgrammeCell")
        radioProgrammesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 92, bottom: 0, right: 92)
        
        // Set up all spacing for each collection view
        if let channelFlowLayout = channelSelectionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            channelFlowLayout.minimumLineSpacing = 0
            channelFlowLayout.minimumInteritemSpacing = 0
        }
        
        if let tvFlowLayout = tvProgrammesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            tvFlowLayout.minimumLineSpacing = 44
            tvFlowLayout.minimumInteritemSpacing = 44
        }
        
        if let radioFlowLayout = radioProgrammesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            radioFlowLayout.minimumLineSpacing = 44
            radioFlowLayout.minimumInteritemSpacing = 44
        }
        
        // Set first channel as selected
        let firstIndexPath = IndexPath(item: 0, section: 0)
        channelSelectionCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
    }
    
    override func refresh() {
        
        // If we've already pulled the programmes for the selected channel
        if let _ = LushPlayerController.shared.channelProgrammes[selectedChannel] {
            redraw()
        } else {
            
            // Fetch the programmes for a specified channel
            LushPlayerController.shared.fetchProgrammes(for: selectedChannel, of: nil, with: { [weak self] (error, programmes) -> (Void) in
                
                // If we get an error, then display it
                if let error = error, let welf = self {
                    UIAlertController.presentError(error, in: welf)
                }
                
                self?.redraw()
            })
        }
    }

    override func redraw() {
        
        // Reload channel selector UI
        channelSelectionCollectionView.reloadData()
        
        // Make sure we have programmes
        guard let programmes = LushPlayerController.shared.channelProgrammes[selectedChannel] else { return }
        
        // Filter programmes by TV or Radio
        tvProgrammes = programmes.filter({$0.media == .TV})
        radioProgrammes = programmes.filter({$0.media == .radio})
        
        // Reload!
        tvProgrammesCollectionView.reloadData()
        radioProgrammesCollectionView.reloadData()
    }
}

extension ChannelsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
        case channelSelectionCollectionView:
            
            return CGSize(width: collectionView.bounds.height * 5/3, height: collectionView.bounds.height)
            
        case tvProgrammesCollectionView, radioProgrammesCollectionView:
            
            return CGSize(width: 320, height: 300)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch collectionView {
        case channelSelectionCollectionView:
            
            // Cell width is determined by the collection view bounds
            let cellWidth = (collectionView.bounds.height * 5/3)
            let totalWidth = CGFloat(LushPlayerController.allChannels.count) * cellWidth
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            // If total width is less than content width, then create left and right insets so everything is centred
            if totalWidth < contentWidth {
                let padding = (contentWidth - totalWidth) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            } else {
                // Otherwise we don't want everything to be centered
                return UIEdgeInsets.zero
            }
            
        default:
            return UIEdgeInsets.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case channelSelectionCollectionView:
            
            // Selected a new channel
            let channel = LushPlayerController.allChannels[indexPath.item]
            if channel != selectedChannel {
                
                // Refresh with new selected channel's content
                selectedChannel = channel
                refresh()
            }
          
        case tvProgrammesCollectionView:
            
            // Show the selected programme
            guard let programme = tvProgrammes?[indexPath.item] else { return }
            show(programme: programme)
            
        case radioProgrammesCollectionView:
            
            // Show the selected programme
            guard let programme = radioProgrammes?[indexPath.item] else { return }
            show(programme: programme)
            
        default:
            print("Unknown collection view")
        }
    }
}

extension ChannelsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case channelSelectionCollectionView:
            return LushPlayerController.allChannels.count
        case tvProgrammesCollectionView:
            return tvProgrammes?.count ?? 0
        case radioProgrammesCollectionView:
            return radioProgrammes?.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case channelSelectionCollectionView:
            
            // Get a channel cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelCell", for: indexPath)
            guard let channelCell = cell as? ChannelCollectionViewCell else { return cell }
            
            // Set the cell's image to the channel's image
            let channel = LushPlayerController.allChannels[indexPath.item]
            channelCell.imageView.image = channel.image()
            
            // Make sure cell is styled correctly for it's selection state
            if channel == selectedChannel {
                channelCell.backgroundColor = UIColor(red:0.439, green:0.439, blue:0.439, alpha:1)
                channelCell.imageView.alpha = 1.0
                channelCell.isSelected = true
            } else {
                channelCell.backgroundColor = UIColor.clear
                channelCell.isSelected = false
            }
            
            return channelCell
        
        case tvProgrammesCollectionView, radioProgrammesCollectionView:
            
            // Get a programme cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath)
            guard let programmeCell = cell as? ChannelProgrammeCollectionViewCell else { return cell }
            
            var programme: Programme?
            
            // Get the correct programme dependent on whether TV or Radio collection view
            if collectionView == tvProgrammesCollectionView {
                programme = tvProgrammes?[indexPath.item]
            } else if collectionView == radioProgrammesCollectionView {
                programme = radioProgrammes?[indexPath.item]
            }
            
            // This guard isn't really necessary, but we'll add it in to satisfy safety and to avoid unconditionally unwrapping.
            guard let _programme = programme else { return programmeCell }
            
            // Set cell's parameters
            programmeCell.imageView.set(imageURL: _programme.thumbnailURL, withPlaceholder: nil, completion: nil)
            programmeCell.titleLabel.text = _programme.title
            programmeCell.dateLabel.text = _programme.date?.timeAgo
            
            programmeCell.titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
            programmeCell.dateLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
            
            return programmeCell
        
        default:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            return cell
        }
    }
}
