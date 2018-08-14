//
//  ViewController.swift
//  TabBarController
//
//  Created by Arnoymous on 08/14/2018.
//  Copyright (c) 2018 Arnoymous. All rights reserved.
//

import UIKit
import TabBarController

class ViewController: TabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controllers = [{ () -> UIViewController in
            let controller = ViewControllerTest()
            controller.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.bookmarks, tag: 0)
            controller.title = "1"
            return controller
            }(), { () -> UIViewController in
                let c = self.storyboard!.instantiateViewController(withIdentifier: "test")
                let controller = UINavigationController(rootViewController: c)
                controller.interactivePopGestureRecognizer?.delegate = nil
                controller.title = "2"
                return controller
            }(), { () -> UIViewController in
                let controller = ViewControllerTest()
                controller.title = "3"
                return controller
            }()]
        
        self.setViewControllers(viewControllers: controllers)
    }
}

class ViewControllerTest: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("tab:\(self.tab.controller)")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class HiddenController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        print("tab:\(self.tab.controller)")
    }
}
