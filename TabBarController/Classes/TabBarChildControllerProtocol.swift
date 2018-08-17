//
//  TabBarChildController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

@objc public protocol TabBarChildControllerProtocol where Self: UIViewController {

    @objc optional weak var additionalTopInsetConstraint: NSLayoutConstraint! { get }
    @objc optional weak var additionalBottomInsetConstraint: NSLayoutConstraint! { get }
    
    @objc optional func updateAdditionalInsets(_ insets: UIEdgeInsets)
    @objc optional func tabBarAction()
}

extension TabBarChildControllerProtocol {
    
    internal func updateAdditionalConstraints(_ insets: UIEdgeInsets) {
        func update(constraint: NSLayoutConstraint??, inset: CGFloat) -> Bool {
            guard let additionalInsetConstraint = constraint as? NSLayoutConstraint,
                additionalInsetConstraint.constant != inset else {
                    return false
            }
            additionalInsetConstraint.constant = inset
            return true
        }
        guard update(constraint: self.additionalTopInsetConstraint, inset: insets.top) ||
            update(constraint: self.additionalBottomInsetConstraint, inset: insets.bottom) else {
                return
        }
        self.view.layoutIfNeeded()
    }
    
    internal func updateAllConstraints(_ insets: UIEdgeInsets) {
        updateAdditionalInsets?(insets)
        updateAdditionalConstraints(insets)
    }
}
