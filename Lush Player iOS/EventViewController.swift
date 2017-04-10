//
//  EventViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 10/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

struct Event {
    
    var id: String
    var title: String
    var programmes: [Programme]
    
}

class EventViewController: ContentListingViewController<Event> {
    
    let eventProgrammeController = EventProgrammeController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "EventCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "EventCollectionViewCellId")
        
        let radioProgrammes = LushPlayerController.shared.programmes[.radio] ?? []
        let tvProgrammes = LushPlayerController.shared.programmes[.TV] ?? []
        
        let programmes = (radioProgrammes + tvProgrammes)
        var tagDictionary = [String: [Programme]]()
        
        for programme in programmes {
            guard let tags = programme.tags else {
                continue
            }
            
            for tag in tags {
                print(tag)
                if var programmeStore = tagDictionary[tag] {
                    programmeStore.append(programme)
                    tagDictionary[tag] = programmeStore
                } else {
                    tagDictionary[tag] = [programme]
                }
            }
        }
        
        
        let summit = Event(id: "summit", title: "Summit 2017", programmes: tagDictionary["summit"] ?? [])
        let showcase =  Event(id: "showcase 2016", title: "Creative Showcase 2016", programmes: tagDictionary["showcase 2016"] ?? [])
        let events = [summit, showcase]
        
        eventProgrammeController.delegate = self
        eventProgrammeController.events = events
        viewState = .loaded(events)

        // Do any additional setup after loading the view.
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCellId", for: indexPath) as? EventCollectionViewCell {
            
            if case let .loaded(events) = viewState {
                
                let event = events[indexPath.item]
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: eventProgrammeController, forRow: indexPath.item)
                cell.eventLabel.text = event.title
                cell.pageControl.numberOfPages = eventProgrammeController.numberOfProgrammesToDisplay(item: indexPath.item)
                
                return cell
                
            }
        }
        
        return UICollectionViewCell()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: collectionView.bounds.width, height: 420)
    }
}


extension EventViewController: EventProgrammeControllerDelegate {

    func eventItemsDidScroll(collectionView: UICollectionView) {
        
        let contentOffset = collectionView.contentOffset
        let centrePoint =  CGPoint(
            x: contentOffset.x + collectionView.frame.midX,
            y: contentOffset.y + collectionView.frame.midY
        )
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: collectionView.tag, section: 0)) as? EventCollectionViewCell else { return }
        
        if let index = collectionView.indexPathForItem(at: centrePoint){
            cell.pageControl.currentPage = index.row
        }
    }
}
