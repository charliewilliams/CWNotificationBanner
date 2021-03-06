//
//  NotificationBanner.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 12/04/2016.
//  Copyright © 2016 Charlie Robert Williams, Ltd. All rights reserved.
//

import UIKit
import SwiftyTimer

public let NotificationBannerShouldDisplayErrorNotification = "NotificationBannerShouldDisplayErrorNotification"

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text && (lhs.date == rhs.date || (lhs.isError && rhs.isError))
}

public enum MessageType: String {
    case NoConnection = "No network connection."
    case ServerError = "Error connecting to the server."
    case Unspecified = "We couldn't complete that request."
    case NotLoggedIn = "Error: Please log out and log in again to continue."
}

public enum PushPayloadKey: String {
    case aps = "aps"
    case alert = "alert"
    case action = "a"
    case duration = "d"
}

public typealias MessageAction = (() -> ())

public struct Message: Equatable {
    public let text: String
    private let date: NSDate
    public let duration: NSTimeInterval
    public var actionKey: String?
    private let isError: Bool
    private static let defaultDisplayTime: NSTimeInterval = 5
    private static var actions = [String:MessageAction]()
    
    public init(text: String, displayDuration: NSTimeInterval = defaultDisplayTime, actionKey: String? = nil, isError error: Bool = false) {
        self.text = text
        self.date = NSDate()
        self.duration = displayDuration
        self.actionKey = actionKey
        self.isError = error
    }

    public init?(pushPayload: [NSObject : AnyObject]) {

        guard let text = pushPayload[PushPayloadKey.aps.rawValue]?[PushPayloadKey.alert.rawValue] as? String else { return nil }
        
        self.text = text
        self.date = NSDate()
        self.actionKey = pushPayload[PushPayloadKey.action.rawValue] as? String
        self.duration = pushPayload[PushPayloadKey.duration.rawValue] as? NSTimeInterval ?? Message.defaultDisplayTime
        self.isError = false
    }
    
    public static func registerAction(action: MessageAction, forKey key: String) {
        actions[key] = action
    }
    
    public static func registerActionsAndKeys(actionsAndKeys:[String:MessageAction]) {
        for (key, action) in actionsAndKeys {
            actions[key] = action
        }
    }

    public static func unregisterActionForKey(key: String) {
        actions.removeValueForKey(key)
    }

    public func isEqual(other: AnyObject?) -> Bool {
        guard let o = other as? Message else { return false }
        return o.text == text && o.date == date
    }
}

public class NotificationBanner: UIView {
    
    public static var animateDuration: NSTimeInterval = 0.3
    public static var fallbackToBannerOnMainWindow: Bool = true
    public static var errorBackgroundColor = UIColor(white: 0.2, alpha: 1.0)
    public static var regularBackgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.2)
    
    override public var backgroundColor: UIColor! {
        didSet {
            underStatusBarView?.backgroundColor = backgroundColor?.colorWithAlphaComponent(0.85)
        }
    }
    
    public static func showMessage(message: Message) {

        guard NSThread.mainThread() == NSThread.currentThread() else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                showMessage(message)
            }
            return
        }
        
        // Don't interrupt an error to show a non-error
        if let currentMessage = pendingMessages.last where currentMessage.isError {
            let index = pendingMessages.count >= 2 ? pendingMessages.count - 2 : 0
            pendingMessages.insert(message, atIndex: index)
            return
        }
        
        // If we're interrupting a message to show an error, re-insert the old message so we show it again
        if let timer = currentMessageTimer,
            let interruptedMessage = pendingMessages.last where timer.valid {
            let index = pendingMessages.count >= 2 ? pendingMessages.count - 2 : 0
            pendingMessages.insert(interruptedMessage, atIndex: index)
        }
        
        if !pendingMessages.contains(message) {
            pendingMessages.append(message)
        }

        sharedToolbar.styleForError(message.isError)
        sharedToolbar.frame = messageHiddenFrame
        sharedToolbar.messageLabel.text = message.text
        
        var translucentNavBar: Bool = false
        
        if let navController = activeNavigationController,
        let navBar = navController.navigationBar as? NavigationBar {
            translucentNavBar = navBar.translucent
            navBar.extraView = sharedToolbar
            navController.navigationBar.insertSubview(sharedToolbar, atIndex: 0)
        }
        else if fallbackToBannerOnMainWindow {
            keyWindow.rootViewController?.view.addSubview(sharedToolbar)
        }
        else {
            return
        }
        
        currentMessage = message
        
        UIView.animateWithDuration(animateDuration) {
            sharedToolbar.frame = messageShownFrame
            sharedToolbar.alpha = 1
        }

        currentMessageTimer?.invalidate()
        currentMessageTimer = NSTimer.after(message.duration) {

            pendingMessages = pendingMessages.filter { $0 != message }
            
            hideCurrentMessage(true, fadeOpacity: translucentNavBar, alreadyRemoved: true) {
                if let next = pendingMessages.last {
                    showMessage(next)
                }
            }
        }
    }
    
    public static func showErrorMessage(messageType: MessageType, code: Int? = nil, duration: NSTimeInterval = Message.defaultDisplayTime) -> Message {
        if messageType == .Unspecified {
            return showErrorMessage(messageType.rawValue, code: code, duration: duration)
        } else {
            return showErrorMessage(messageType.rawValue, code: nil, duration: duration)
        }
    }
    
    public static func showErrorMessage(text: String, code: Int? = nil, duration: NSTimeInterval = Message.defaultDisplayTime) -> Message {
        
        var text = text
        if let code = code where code != 0 {
            text = String(text.characters.dropLast()) + ": \(code)"
        }
        let message = Message(text: text, displayDuration: duration, isError: true)
        showMessage(message)
        
        return message
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

    private static var keyWindow: UIWindow {
        return UIApplication.sharedApplication().keyWindow!
    }
    private static var activeNavigationController: UINavigationController? {
        let rootVC = keyWindow.rootViewController!
            
        if let navController = rootVC as? UINavigationController {
            return navController
        }
        else if let navController = rootVC.navigationController {
            return navController
        }
        else if let tabBarController = rootVC as? UITabBarController {
            
            let selectedVC = tabBarController.selectedViewController!
            if let navController = selectedVC as? UINavigationController {
                
                if let visibleViewController = navController.visibleViewController,
                    let visibleNavController = visibleViewController.navigationController {
                    return visibleNavController
                }
                else { return navController }
            }
            else if let navController = selectedVC.navigationController {
                return navController
            }
        }
        else if let navController = rootVC.childViewControllers.first?.navigationController {
            return navController
        }
        
        return nil
    }
    
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    private var underStatusBarView: UIView?
    
    private static var sharedToolbar: NotificationBanner = {
        
        let b = NSBundle(forClass: NotificationBanner.classForCoder())
        let t = b.loadNibNamed(String(NotificationBanner), owner: nil, options: nil).first as! NotificationBanner
        t.messageButton.addTarget(t, action: #selector(NotificationBanner.messageLabelTapped(_:)), forControlEvents: .TouchUpInside)
        t.closeButton.addTarget(t, action: #selector(NotificationBanner.closeButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationBannerShouldDisplayErrorNotification, object: nil, queue: .mainQueue(), usingBlock: { (notification:NSNotification) in
            
            if let error = notification.object as? NSError {
                NotificationBanner.showErrorMessage(error.localizedDescription)
            } else if let errorText = notification.object as? String {
                NotificationBanner.showErrorMessage(errorText)
            } else {
                NotificationBanner.showErrorMessage(.Unspecified)
            }
        })
        
        return t
    }()

    private static var currentMessageTimer: NSTimer?
    private static var currentMessage: Message?
    private static var pendingMessages = [Message]()
    
    private class var messageShownFrame: CGRect {
        
        let y: CGFloat
        
        if let navigationBar = activeNavigationController?.navigationBar where sharedToolbar.superview == navigationBar {
            y = navigationBar.frame.height
        } else {
            y = UIApplication.sharedApplication().statusBarHidden ? 0 : UIApplication.sharedApplication().statusBarFrame.height
        }
        
        return CGRect(x: 0, y: y, width: UIScreen.mainScreen().bounds.width, height: sharedToolbar.frame.height)
    }
    private class var messageHiddenFrame: CGRect {
        return CGRect(x: 0, y: -sharedToolbar.frame.height, width: UIScreen.mainScreen().bounds.width, height: sharedToolbar.frame.height)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private static func hideCurrentMessage(animated: Bool, fadeOpacity: Bool = false, alreadyRemoved: Bool = false, completion: (()->())? = nil) {
        
        if !alreadyRemoved && pendingMessages.count > 0 {
            pendingMessages.removeLast()
        }

        if animated {
            UIView.animateWithDuration(animateDuration, animations: {
                sharedToolbar.frame = messageHiddenFrame
                if fadeOpacity {
                    sharedToolbar.alpha = 0
                }
                }, completion: { finished in
                    sharedToolbar.alpha = 0
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

    @IBAction @objc private func messageLabelTapped(sender: UIButton) {
        if let key = NotificationBanner.currentMessage?.actionKey,
            let action = Message.actions[key] {
            action()
        }
    }
    
    @IBAction @objc private func closeButtonTapped(sender: UIButton) {
        NotificationBanner.hideCurrentMessage(true) {
            if let next = NotificationBanner.pendingMessages.last {
                NotificationBanner.showMessage(next)
            }
        }
    }
    
    private func styleForError(isError: Bool) {
        backgroundColor = isError ? NotificationBanner.errorBackgroundColor : NotificationBanner.regularBackgroundColor
        messageLabel.textColor = .whiteColor()
    }
    
    private func addStatusBarBackingView() {
        let underStatusBar = UIView(frame: CGRectZero)
        underStatusBar.backgroundColor = backgroundColor.colorWithAlphaComponent(0.85) //UIColor(white: 0.2, alpha: 0.85)
        underStatusBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underStatusBar)
        let views = ["underStatusBar":underStatusBar]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[underStatusBar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(-20)-[underStatusBar(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        underStatusBarView = underStatusBar
    }
}
