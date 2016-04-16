//
//  ViewController.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 12/04/2016.
//  Copyright © 2016 Charlie Robert Williams, Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let message = Message(text: "Hello there", action: {
            
        })
        
        NotificationBanner.showMessage(message)
    }
    
    var count: Int = 0
    @IBAction func sendPushPressed(sender: UIButton) {
        
        let message = Message(text: "Hello there, this is message \(count)", action: {
            
        })
        
        NotificationBanner.showMessage(message)
        
        count += 1
    }
    

}

