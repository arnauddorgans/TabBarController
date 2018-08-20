//
//  FacebookTabBarController.swift
//  TabBarController
//
//  Created by Arnoymous on 08/14/2018.
//  Copyright (c) 2018 Arnoymous. All rights reserved.
//

import UIKit
import TabBarController

class FacebookTabBarController: TabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
}

extension FacebookTabBarController: TabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: TabBarController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let fromIndex = tabBarController.viewControllers?.index(of: fromVC),
            let toIndex = tabBarController.viewControllers?.index(of: toVC) else {
                return nil
        }
        return FacebookTabBarTransition(isReversed: toIndex < fromIndex)
    }
}
