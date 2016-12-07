//
//  RefreshableViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit
import AVKit

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
    
    func show(programme: Programme) {
        performSegue(withIdentifier: "ShowProgramme", sender: programme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let programme = sender as? Programme else { return }
        guard let detailVC = segue.destination as? LiveViewController else { return }
        
        detailVC.programme = programme
    }
}
