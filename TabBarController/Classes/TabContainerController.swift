//
//  TabContainerController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

protocol TabContainerControllerDelegate: class {
    
    func tabContainerController(_ tabContainerController: TabContainerController, willShow viewController: UIViewController?)
    func tabContainerController(_ tabContainerController: TabContainerController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
}

internal class TabContainerController: UINavigationController {
    
    weak var _tabBarController: TabBarController?
    weak var containerDelegate: TabContainerControllerDelegate?
    
    var viewController: UIViewController? {
        return self.viewControllers.last
    }
    
    init(tabBarController: TabBarController) {
        self._tabBarController = tabBarController
        self.containerDelegate = tabBarController
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isNavigationBarHidden = true
        self.delegate = self
    }
    
    func setViewController(_ viewController: UIViewController?, source: TabBarControllerUpdateSource) {
        if viewController != self.viewController {
            let animated = source == .action && self.viewController.flatMap { fromVC in
                viewController.flatMap { toVC in
                    self.containerDelegate?.tabContainerController(self, animationControllerFrom: fromVC, to: toVC)
                }
            } != nil
            self.setViewControllers(viewController.flatMap { [$0] } ?? [], animated: animated)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabContainerController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.containerDelegate?.tabContainerController(self, willShow: viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.containerDelegate?.tabContainerController(self, animationControllerFrom: fromVC, to: toVC)
    }
}
