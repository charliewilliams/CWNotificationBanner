//
//  NavigationBar.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 17/05/2016.
//
//

import UIKit

class NavigationBar: UINavigationBar {
    
    var extraView: UIView?
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        self.userInteractionEnabled = self.pointInside(point, withEvent: event)
        
        return super.hitTest(point, withEvent: event)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        var extendedRect = self.frame
        
        if let extraView = extraView {
            extendedRect = CGRectUnion(extendedRect, extraView.frame)
        }
        
        return CGRectContainsPoint(extendedRect, point)
    }
}
