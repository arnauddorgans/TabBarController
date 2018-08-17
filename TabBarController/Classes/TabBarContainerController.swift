//
//  TabBarContainerController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

protocol TabBarContainerControllerDelegate: class {
    
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, willShow viewController: UIViewController?)
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}

internal class TabBarContainerController: UINavigationController {
    
    var isAnimating: Bool = false
    weak var containerDelegate: TabBarContainerControllerDelegate?
    
    var viewController: UIViewController? {
        return self.viewControllers.last
    }
    
    init(tabBarController: TabBarController) {
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
            #if os(iOS)
            let animated = source == .action && self.viewController.flatMap { fromVC in
                viewController.flatMap { toVC in
                    self.containerDelegate?.tabBarContainerController(self, animationControllerFrom: fromVC, to: toVC)
                }
            } != nil
            #elseif os(tvOS)
            let animated = true
            #endif
            self.setViewControllers(viewController.flatMap { [$0] } ?? [], animated: animated)
        }
    }
    
    #if os(iOS)
    override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return viewController
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return viewController
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return viewController
    }
    #endif
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBarContainerController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.isAnimating = animated
        self.containerDelegate?.tabBarContainerController(self, willShow: viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.isAnimating = false
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.containerDelegate?.tabBarContainerController(self, animationControllerFrom: fromVC, to: toVC)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.containerDelegate?.tabBarContainerController(self, interactionControllerFor: animationController)
    }
}
