//
//  UIViewController+TabBarChildControllerProtocol.swift
//  Pods
//
//  Created by Arnaud Dorgans on 19/08/2018.
//

import UIKit

extension UIViewController: TabBarChildControllerProtocol {
    
}

extension TabBarController {
    
    @available(iOS 11.0, tvOS 11.0, *)
    public func updateTabBarInsets(_ insets: UIEdgeInsets) {
        self.updateSafeArea(insets: insets)
    }
}

extension TabBarNavigationContainerController {
    
    public func tabBarAction() {
        self.viewController.tabBarAction()
    }
    
    public func updateTabBarInsets(_ insets: UIEdgeInsets) {
        self.viewController.updateTabBarInsets(insets)
    }
}

extension UINavigationController {
    
    private var viewController: TabBarChildControllerProtocol? {
        return self.viewControllers.last
    }
    
    public func tabBarAction() {
        if self.viewControllers.count > 1 {
            self.popToRootViewController(animated: true)
        } else {
            self.viewController?.tabBarAction?()
        }
    }
    
    public func updateTabBarInsets(_ insets: UIEdgeInsets) {
        self.viewController?.updateAllTabBarConstraints(insets)
    }
}
