//
//  NavContainerController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

internal class NavContainerController: UIViewController {
    
    var controller: UINavigationController
    weak var _tabBarController: TabBarController?
    weak var forwardDelegate: UINavigationControllerDelegate?
    
    override var title: String? {
        get { return controller.title }
        set { controller.title = newValue }
    }
    
    override var tabBarItem: UITabBarItem! {
        get { return controller.tabBarItem }
        set { controller.tabBarItem = newValue }
    }
    
    init?(controller: UIViewController, tabBarController: TabBarController) {
        guard let controller = controller as? UINavigationController else {
            return nil
        }
        self.controller = controller
        self._tabBarController = tabBarController
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller.willMove(toParentViewController: self)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(controller.view)
        controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)
        
        self.forwardDelegate = controller.delegate
        controller.delegate = self
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return controller
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return controller
    }
    
    override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return controller
    }
    
    override func childViewControllerForScreenEdgesDeferringSystemGestures() -> UIViewController? {
        return controller
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NavContainerController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        _tabBarController?.navigationController(navigationController, didShow: viewController, animated: animated)
        forwardDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        _tabBarController?.navigationController(navigationController, willShow: viewController, animated: animated)
        forwardDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return forwardDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return forwardDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}
