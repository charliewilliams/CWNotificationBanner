//
//  PopDownOverlayBar.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 12/04/2016.
//  Copyright © 2016 Charlie Robert Williams, Ltd. All rights reserved.
//

import UIKit
import SwiftyTimer

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text && lhs.date == rhs.date
}

public struct Message : Equatable {
    public let text: String
    public let action: () -> ()
    public let duration: NSTimeInterval
    private let date: NSDate
    
    public init(text: String, action: () -> (), displayDuration: NSTimeInterval = 5) {
        self.text = text
        self.action = action
        self.date = NSDate()
        self.duration = displayDuration
    }
    
    public func isEqual(other: AnyObject?) -> Bool {
        guard let o = other as? Message else { return false }
        return o.text == text && o.date == date
    }
}

public class PopDownOverlayBar: UIToolbar {

    public static func showMessage(message: Message) {
        
        guard NSThread.mainThread() == NSThread.currentThread() else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                showMessage(message)
            }
            return
        }
        
        if !pendingMessages.contains(message) {
            pendingMessages.append(message)
        }
        
        sharedToolbar.frame = messageHiddenFrame
        sharedToolbar.messageLabel.text = message.text
        
        UIView.animateWithDuration(animateDuration) { 
            sharedToolbar.frame = messageShownFrame
        }
        
        currentMessageTimer?.invalidate()
        currentMessageTimer = NSTimer.after(message.duration) {
            
            pendingMessages = pendingMessages.filter { $0 != message }
            
            hideCurrentMessage(true) {
                if let next = pendingMessages.last {
                    showMessage(next)
                }
            }
        }
    }
    
    public static func cancelMessage(toCancel: Message, animated: Bool = true) {
        guard NSThread.mainThread() == NSThread.currentThread() else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                cancelMessage(toCancel, animated: animated)
            }
            return
        }
        
        if let current = currentMessage where toCancel == current {
            hideCurrentMessage(animated)
        } else {
            pendingMessages = pendingMessages.filter { $0 != toCancel }
        }
    }
    
    public static func cancelAllMessages(animated: Bool) {
        guard NSThread.mainThread() == NSThread.currentThread() else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                cancelAllMessages(animated)
            }
            return
        }
        
        hideCurrentMessage(animated)
        pendingMessages = []
    }

    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var messageLabel: UILabel!
    public static var sharedToolbar: PopDownOverlayBar = {
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        let t = NSBundle.mainBundle().loadNibNamed(String(PopDownOverlayBar), owner: nil, options: nil).first as! PopDownOverlayBar
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
    
    private static func hideCurrentMessage(animated: Bool, completion: (()->())? = nil) {
        
        if pendingMessages.count > 0 {
            pendingMessages.removeLast()
        }
        
        if animated {
            UIView.animateWithDuration(animateDuration, animations: {
                sharedToolbar.frame = messageHiddenFrame
                }, completion: { finished in
                    completion?()
            })
        } else {
            sharedToolbar.frame = messageHiddenFrame
            completion?()
        }
        
        currentMessageTimer?.invalidate()
        currentMessageTimer = nil
        currentMessage = nil
    }

    @IBAction func popoverTapped(sender: UIBarButtonItem) {
        PopDownOverlayBar.currentMessage?.action()
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        PopDownOverlayBar.hideCurrentMessage(true) {
            if let next = PopDownOverlayBar.pendingMessages.last {
                PopDownOverlayBar.showMessage(next)
            }
        }
    }
}
