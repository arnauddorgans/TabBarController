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
        self.delegate = self
    }
}

extension ViewController: TabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: TabBarController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let fromIndex = tabBarController.viewControllers?.index(of: fromVC),
            let toIndex = tabBarController.viewControllers?.index(of: toVC) else {
                return nil
        }
        return FacebookTabBarTransition(isNext: toIndex > fromIndex)
    }
}

class ViewControllerTest: UIViewController, TabBarChildControllerProtocol {

    @IBOutlet weak var additionalTopInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalBottomInsetConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

#if os(iOS)

class HiddenController: ViewControllerTest {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
    }
    
    @IBAction func switchTab(_ sender: Any) {
        guard let controller = self.tab.controller else {
            return
        }
        self.hidesBottomBarWhenPushed = !controller.isTabBarHidden
        controller.setTabBarHidden(self.hidesBottomBarWhenPushed, animated: true)
    }
}
#endif
