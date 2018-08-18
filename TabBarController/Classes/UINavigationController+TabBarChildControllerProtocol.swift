//
//  UINavigationController+TabBarChildControllerProtocol.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 15/08/2018.
//

import UIKit

extension UINavigationController: TabBarChildControllerProtocol {
    
    public func tabBarAction() {
        if self.viewControllers.count > 1 {
            self.popToRootViewController(animated: true)
        } else {
            (self.viewControllers.last as? TabBarChildControllerProtocol)?.tabBarAction?()
        }
    }
    
    public func updateAdditionalInsets(_ insets: UIEdgeInsets) {
        (self.viewControllers.last as? TabBarChildControllerProtocol)?.updateAllAdditionalInsets(insets)
    }
}
