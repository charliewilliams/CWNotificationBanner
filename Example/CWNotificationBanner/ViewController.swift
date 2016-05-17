//
//  ViewController.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 04/16/2016.
//  Copyright (c) 2016 Charlie Williams. All rights reserved.
//

import CWNotificationBanner

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapAction:MessageAction = { Void in
            
            let alert = UIAlertController(title: "Tapped the alert banner", message: "Popups are a terrible user experience, eh?", preferredStyle: .Alert)
            self.showViewController(alert, sender: nil)
        }
        
        Message.registerAction(tapAction, forKey: "tapAction")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let message = Message(text: "Hello there")
        
        NotificationBanner.showMessage(message)
    }
    
    var count: Int = 0
    @IBAction func sendPushPressed(sender: UIButton) {
        
        let message = Message(text: "Hello there, this is message \(count)", actionKey: "tapAction")
        
        NotificationBanner.showMessage(message)
        
        count += 1
    }
}
