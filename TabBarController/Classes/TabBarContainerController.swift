//
//  TabBarContainerController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

protocol TabBarContainerControllerDelegate: class {
    
    func tabBarContainerController(_ TabBarContainerController: TabBarContainerController, willShow viewController: UIViewController?)
    func tabBarContainerController(_ TabBarContainerController: TabBarContainerController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
}

internal class TabBarContainerController: UINavigationController {
    
    weak var _tabBarController: TabBarController?
    weak var containerDelegate: TabBarContainerControllerDelegate?
    
    var viewController: UIViewController? {
        return self.viewControllers.last
    }
    
    init(tabBarController: TabBarController) {
        self._tabBarController = tabBarController
        self.containerDelegate = tabBarController
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isNavigationBarHidden = true
    }
    
    func setViewController(_ viewController: UIViewController?, source: TabBarControllerUpdateSource) {
        if viewController != self.viewController {
            let animated = source == .action && self.viewController.flatMap { fromVC in
                viewController.flatMap { toVC in
                    self.containerDelegate?.tabBarContainerController(self, animationControllerFrom: fromVC, to: toVC)
                }
            } != nil
            self.setViewControllers(viewController.flatMap { [$0] } ?? [], animated: animated)
        }
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBarContainerController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.containerDelegate?.tabBarContainerController(self, willShow: viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.containerDelegate?.tabBarContainerController(self, animationControllerFrom: fromVC, to: toVC)
    }
}
