//
//  TabBarChildController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

@objc public protocol TabBarChildControllerProtocol: class {
    
    @objc optional weak var additionalInsetConstraint: NSLayoutConstraint! { get }
    @objc optional func updateAdditionalInset(_ inset: CGFloat)
    
    @objc optional func tabBarAction()
}

extension TabBarChildControllerProtocol {
    
    internal func updateAdditionalConstraint(_ inset: CGFloat) {
        self.additionalInsetConstraint??.constant = inset
    }
    
    internal func updateAllConstraints(_ inset: CGFloat) {
        updateAdditionalInset?(inset)
        updateAdditionalConstraint(inset)
    }
}
