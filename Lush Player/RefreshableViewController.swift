//
//  RefreshableViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import AVKit
import LushPlayerKit

/// A base view controller which adds refreshable capabilities to UIViewController
class RefreshableViewController: UIViewController {
    
    private var refreshObserver: NSObjectProtocol?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        refresh()
        
        // Set up an observer to listen for program refresh notifications
        refreshObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.ProgrammesRefreshed, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            // Call redraw function
            self?.redraw()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// A function responsible for refreshing the content associated with this view controller
    func refresh() {
        
    }

    /// A function responsible for redrawing the content of this view controller when a refresh occurs
    func redraw() {
        
    }
    
    /// Pushes a specific `Programme` object onto the navigation stack
    ///
    /// - Parameter programme: The programme to push
    func show(programme: Programme) {
        performSegue(withIdentifier: "ShowProgramme", sender: programme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If the sender is a Programme object
        guard let programme = sender as? Programme else { return }
        // And the destination is the `LiveViewController`
        guard let detailVC = segue.destination as? LiveViewController else { return }
        
        // Set the pushing VC's programme up
        detailVC.programme = programme
    }
}
