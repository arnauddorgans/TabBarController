//
//  TabBarNavigationContainerController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

public class TabBarNavigationContainerController: UIViewController {
    
    let controller: UINavigationController
    
    override public var title: String? {
        get { return controller.title }
        set { controller.title = newValue }
    }
    
    override public var tabBarItem: UITabBarItem! {
        get { return controller.tabBarItem }
        set { controller.tabBarItem = newValue }
    }
    
    init?(controller: UIViewController, tabBarController: TabBarController) {
        guard let controller = controller as? UINavigationController else {
            return nil
        }
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
        controller.delegate = tabBarController
    }
    
    override public func viewDidLoad() {
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
    }
    
    override public var childViewControllerForStatusBarStyle: UIViewController? {
        return controller
    }
    
    override public var childViewControllerForStatusBarHidden: UIViewController? {
        return controller
    }
    
    override public func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return controller
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBarNavigationContainerController: TabBarChildControllerProtocol {
    
    public func tabBarAction() {
        controller.tabBarAction()
    }
    
    public func updateAdditionalInsets(_ insets: UIEdgeInsets) {
        self.controller.updateAdditionalInsets(insets)
    }
}
