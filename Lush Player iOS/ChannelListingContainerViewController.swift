//
//  ChannelListingContainerViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 27/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class ChannelListingContainerViewController: UIViewController {
    
    var channel: Channel!
    
    var childListingViewController: ChannelListingViewController? {
        return childViewControllers.filter({ $0 is ChannelListingViewController}).first as? ChannelListingViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ChannelListingViewControllerId") as? ChannelListingViewController else { return }
        viewController.selectedChannel = channel
        
        addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        didMove(toParentViewController: viewController)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
