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
    
    private func update(constraint: NSLayoutConstraint??, inset: CGFloat) -> Bool {
        guard let additionalInsetConstraint = constraint as? NSLayoutConstraint,
            additionalInsetConstraint.constant != inset else {
                return false
        }
        additionalInsetConstraint.constant = inset
        return true
    }
    
    internal func updateAdditionalConstraints(_ insets: UIEdgeInsets) {
        let controller = self as TabBarChildControllerProtocol
        guard update(constraint: controller.additionalTopInsetConstraint, inset: insets.top) ||
            update(constraint: controller.additionalBottomInsetConstraint, inset: insets.bottom) else {
                return
        }
        self.view.layoutIfNeeded()
    }
    
    internal func updateAllAdditionalInsets(_ insets: UIEdgeInsets) {
        var controller: TabBarChildControllerProtocol? = self
        if #available(iOS 11.0, tvOS 11.0, *) {
            if !(self is TabBarController) {
                controller = self.tab.controller
            }
        }
        controller?.updateAdditionalInsets?(insets)
        controller?.updateAdditionalConstraints(insets)        
    }
}
