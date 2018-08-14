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
    
    internal init(base: UIViewController) {
        self.base = base
    }
}

