//
//  RefreshableViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class RefreshableViewController: UIViewController {
    
    private var refreshObserver: NSObjectProtocol?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        refresh()
        
        refreshObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.ProgrammesRefreshed, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            self?.redraw()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        
    }

    func redraw() {
        
    }
}
