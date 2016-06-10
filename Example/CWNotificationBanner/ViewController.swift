//
//  ViewController.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 04/16/2016.
//  Copyright (c) 2016 Charlie Williams. All rights reserved.
//

import CWNotificationBanner

extension UIColor {
    static func randomColor() -> UIColor {
        return UIColor(hue: CGFloat.random, saturation: CGFloat.random, brightness: CGFloat.random, alpha: 1)
    }
}

extension CGFloat {
    static var random:CGFloat {
        return CGFloat(arc4random_uniform(1000)) / 1000
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapAction:MessageAction = { [weak self] Void in
            self?.view.backgroundColor = .randomColor()
        }
        
        Message.registerAction(tapAction, forKey: "tapAction")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let message = Message(text: "This is just a regular banner")
        
        NotificationBanner.showMessage(message)
    }
    
    var count: Int = 0
    @IBAction func sendPushPressed(sender: UIButton) {
        
        let message = Message(text: "This is message \(count). Tap me!", actionKey: "tapAction")
        
        NotificationBanner.showMessage(message)
        
        count += 1
    }
}
