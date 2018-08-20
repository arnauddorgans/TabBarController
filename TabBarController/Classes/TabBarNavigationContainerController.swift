//
//  TabBarNavigationContainerController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

class TabBarNavigationContainerController: UIViewController {
    
    let viewController: UINavigationController
    
    override var title: String? {
        get { return viewController.title }
        set { viewController.title = newValue }
    }
    
    override var tabBarItem: UITabBarItem! {
        get { return viewController.tabBarItem }
        set { viewController.tabBarItem = newValue }
    }
    
    init?(viewController: UIViewController, delegate: UINavigationControllerDelegate) {
        guard let viewController = viewController as? UINavigationController else {
            return nil
        }
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
        viewController.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewController.willMove(toParentViewController: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(viewController.view)
        viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
    }
    
    #if os(iOS)
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return viewController
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return viewController
    }
    
    override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return viewController
    }
    #endif
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
