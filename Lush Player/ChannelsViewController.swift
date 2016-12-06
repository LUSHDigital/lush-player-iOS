//
//  ChannelsViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class ChannelsViewController: RefreshableViewController {
    
    @IBOutlet weak var channelSelectionCollectionView: UICollectionView!
    
    @IBOutlet weak var tvProgrammesCollectionView: UICollectionView!
    
    @IBOutlet weak var radioProgrammesCollectionView: UICollectionView!
    
    var selectedChannel: Channel = .life
    
    var radioProgrammes: [Programme]?
    
    var tvProgrammes: [Programme]?

    override func viewDidLoad() {
        
        super.viewDidLoad()

        let nib = UINib(nibName: "ChannelCollectionViewCell", bundle: nil)
        channelSelectionCollectionView.register(nib, forCellWithReuseIdentifier: "ChannelCell")
        
        let programmeNib = UINib(nibName: "ProgrammeCollectionViewCell", bundle: nil)
        tvProgrammesCollectionView.register(programmeNib, forCellWithReuseIdentifier: "ProgrammeCell")
        tvProgrammesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 92, bottom: 0, right: 92)
        
        radioProgrammesCollectionView.register(programmeNib, forCellWithReuseIdentifier: "ProgrammeCell")
        radioProgrammesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 92, bottom: 0, right: 92)
        
        if let channelFlowLayout = channelSelectionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            channelFlowLayout.minimumLineSpacing = 0
            channelFlowLayout.minimumInteritemSpacing = 0
        }
        
        let firstIndexPath = IndexPath(item: 0, section: 0)
        channelSelectionCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
    }
    
    override func refresh() {
        
        if let _ = LushPlayerController.shared.channelProgrammes[selectedChannel] {
            redraw()
        } else {
            
            LushPlayerController.shared.fetchProgrammes(for: selectedChannel, of: nil, with: { [weak self] (error, programmes) -> (Void) in
                
                if let error = error, let welf = self {
                    UIAlertController.presentError(error, in: welf)
                }
                
                self?.redraw()
            })
        }
    }

    override func redraw() {
        
        channelSelectionCollectionView.reloadData()
        
        guard let programmes = LushPlayerController.shared.channelProgrammes[selectedChannel] else { return }
        
        tvProgrammes = programmes.filter({$0.media == .TV})
        radioProgrammes = programmes.filter({$0.media == .radio})
        
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
            
            let cellWidth = (collectionView.bounds.height * 5/3)
            let totalWidth = CGFloat(LushPlayerController.allChannels.count) * cellWidth
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if totalWidth < contentWidth {
                let padding = (contentWidth - totalWidth) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            } else {
                return UIEdgeInsets.zero
            }
            
        default:
            return UIEdgeInsets.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case channelSelectionCollectionView:
            
            let channel = LushPlayerController.allChannels[indexPath.item]
            if channel != selectedChannel {
                
                selectedChannel = channel
                refresh()
            }
          
        case tvProgrammesCollectionView:
            
            guard let programme = tvProgrammes?[indexPath.item] else { return }
            play(programme: programme)
            
        case radioProgrammesCollectionView:
            
            guard let programme = radioProgrammes?[indexPath.item] else { return }
            play(programme: programme)
            
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelCell", for: indexPath)
            guard let channelCell = cell as? ChannelCollectionViewCell else { return cell }
            
            let channel = LushPlayerController.allChannels[indexPath.item]
            channelCell.imageView.image = channel.image()
            
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath)
            guard let programmeCell = cell as? ProgrammeCollectionViewCell else { return cell }
            
            var programme: Programme?
            
            if collectionView == tvProgrammesCollectionView {
                programme = tvProgrammes?[indexPath.item]
            } else if collectionView == radioProgrammesCollectionView {
                programme = radioProgrammes?[indexPath.item]
            }
            
            guard let _programme = programme else { return programmeCell }
            
            programmeCell.imageView.set(imageURL: _programme.thumbnailURL, withPlaceholder: nil, completion: nil)
            programmeCell.formatLabel.text = _programme.media.displayString()
            programmeCell.titleLabel.text = _programme.title
            programmeCell.dateLabel.text = _programme.date?.timeAgo
            
            return programmeCell
        
        default:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            return cell
        }
    }
}
