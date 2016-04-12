//
//  PopDownOverlayBar.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 12/04/2016.
//  Copyright © 2016 Charlie Robert Williams, Ltd. All rights reserved.
//

import UIKit

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text && lhs.date == rhs.date
}

public struct Message : Equatable {
    public let text: String
    public let action: () -> ()
    private let date: NSDate
    
    public init(text: String, action: () -> ()) {
        self.text = text
        self.action = action
        self.date = NSDate()
    }
    
    public func isEqual(other: AnyObject?) -> Bool {
        guard let o = other as? Message else { return false }
        return o.text == text && o.date == date
    }
}

public class PopDownOverlayBar: UIToolbar {

    public static func showMessage(message: Message) {
        
        UIView.animateWithDuration(animateDuration) { 
            sharedToolbar.frame = messageShownFrame
        }
        
        currentMessageTimer = NSTimer.scheduledTimerWithTimeInterval(<#T##ti: NSTimeInterval##NSTimeInterval#>, target: <#T##AnyObject#>, selector: <#T##Selector#>, userInfo: <#T##AnyObject?#>, repeats: <#T##Bool#>)
    }
    
    public static func cancelMessage(toCancel: Message, animated: Bool = true) {
        
        if let current = currentMessage where toCancel == current {
            hideCurrentMessage(animated)
        } else {
            pendingMessages = pendingMessages.filter { $0 != toCancel }
        }
    }
    
    public static func cancelAllMessages(animated: Bool) {
        pendingMessages = []
        hideCurrentMessage(animated)
    }

    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var messageLabel: UILabel!
    public static var sharedToolbar: PopDownOverlayBar = {
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        let t = NSBundle.mainBundle().loadNibNamed(String(PopDownOverlayBar), owner: nil, options: nil).first as! PopDownOverlayBar
        t.frame = messageHiddenFrame
        keyWindow.addSubview(t)
        return t
    }()
    
    private static var currentMessageTimer: NSTimer?
    private static var currentMessage: Message?
    private static var pendingMessages = [Message]()
    
    private static let animateDuration: NSTimeInterval = 0.3
    private static var messageShownFrame: CGRect {
        return CGRect(x: 0, y: 0, width: sharedToolbar.frame.width, height: sharedToolbar.frame.height)
    }
    private static var messageHiddenFrame: CGRect {
        return CGRect(x: 0, y: -sharedToolbar.frame.height, width: sharedToolbar.frame.width, height: sharedToolbar.frame.height)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private static func hideCurrentMessage(animated: Bool) {
        
        if animated {
            UIView.animateWithDuration(animateDuration) {
                sharedToolbar.frame = messageHiddenFrame
            }
        } else {
            sharedToolbar.frame = messageHiddenFrame
        }
        
        currentMessageTimer?.invalidate()
        currentMessageTimer = nil
        currentMessage = nil
    }

    @IBAction func popoverTapped(sender: UIBarButtonItem) {
        PopDownOverlayBar.currentMessage?.action()
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        PopDownOverlayBar.hideCurrentMessage(true)
    }
    
}
