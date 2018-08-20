//
//  Tab.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

public struct Tab {
    
    private let base: UIViewController
    
    public var controller: TabBarController? {
        if let controller = self.base as? TabBarController {
            return controller
        }
        return self.base.parent?.tab.controller
    }
    
    public var bar: TabBar? {
        return controller?.tabBar
    }
    
    public var barItem: UITabBarItem? {
        guard !(self.base is TabBarController) else {
            return nil
        }
        guard self.controller?.viewControllers?.contains(self.base) == true else {
            return self.base.parent?.tab.barItem
        }
        return self.base.tabBarItem
    }
    
    public var isNavigationController: Bool {
        return navigationController != nil
    }
    
    public var navigationController: UINavigationController? {
        return (self.base as? TabBarNavigationContainerController)?.viewController
    }
    
    internal init(base: UIViewController) {
        self.base = base
    }
}

