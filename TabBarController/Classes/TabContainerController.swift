//
//  TabContainerController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

internal class TabContainerController: UINavigationController {
    
    weak var _tabBarController: TabBarController?
    private var viewController: UIViewController? {
        return self.viewControllers.last
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isNavigationBarHidden = true
        self.delegate = self
    }
    
    func setViewController(_ viewController: UIViewController?) {
        if viewController != self.viewController {
            self.setViewControllers(viewController.flatMap { [$0] } ?? [], animated: false)
        }
    }
    
    override func childViewControllerForScreenEdgesDeferringSystemGestures() -> UIViewController? {
        return viewController
    }
    
    override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return viewController
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return viewController
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return viewController
    }
}

extension TabContainerController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
}
