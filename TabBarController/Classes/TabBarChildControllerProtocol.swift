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
            update(constraint: controller.tabBarBottomInsetConstraint, inset: insets.bottom) else {
                return
        }
        self.view.layoutIfNeeded()
    }
    
    internal func updateAllTabBarConstraints(_ insets: UIEdgeInsets) {
        self.loadViewIfNeeded()

        var controller: TabBarChildControllerProtocol? = self
        if #available(iOS 11.0, tvOS 11.0, *) {
            controller = self.tab.controller
        }
        controller?.updateTabBarInsets?(insets)
        controller?.updateTabBarConstraints(insets)
    }
}
