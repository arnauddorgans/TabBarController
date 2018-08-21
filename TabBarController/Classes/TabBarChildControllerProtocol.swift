//
//  TabBarChildController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

@objc public protocol TabBarChildControllerProtocol where Self: UIViewController {

    @objc optional weak var tabBarTopInsetConstraint: NSLayoutConstraint! { get }
    @objc optional weak var tabBarBottomInsetConstraint: NSLayoutConstraint! { get }
    @objc optional weak var tabBarLeadingInsetConstraint: NSLayoutConstraint! { get }
    @objc optional weak var tabBarTrailingInsetConstraint: NSLayoutConstraint! { get }
    
    @objc optional func updateTabBarInsets(_ insets: UIEdgeInsets)
    @objc optional func tabBarAction()
}

extension TabBarChildControllerProtocol {
    
    public var tab: Tab {
        return Tab(base: self)
    }
    
    private func update(constraint: NSLayoutConstraint??, inset: CGFloat) -> Bool {
        guard let additionalInsetConstraint = constraint as? NSLayoutConstraint,
            additionalInsetConstraint.constant != inset else {
                return false
        }
        additionalInsetConstraint.constant = inset
        return true
    }
    
    internal func updateTabBarConstraints(_ insets: UIEdgeInsets) {
        let controller = self as TabBarChildControllerProtocol
        guard update(constraint: controller.tabBarTopInsetConstraint, inset: insets.top) ||
            update(constraint: controller.tabBarBottomInsetConstraint, inset: insets.bottom) ||
            update(constraint: controller.tabBarLeadingInsetConstraint, inset: insets.left) ||
            update(constraint: controller.tabBarTrailingInsetConstraint, inset: insets.right) else {
                return
        }
        self.view.layoutIfNeeded()
    }
    
    internal func updateAllTabBarConstraints(_ insets: UIEdgeInsets) {
        var controller: TabBarChildControllerProtocol? = self
        if #available(iOS 11.0, tvOS 11.0, *) {
            controller = self.tab.controller
        } else {
            (controller as? UIViewController)?.loadViewIfNeeded()
        }
        controller?.updateTabBarInsets?(insets)
        controller?.updateTabBarConstraints(insets)
    }
}
