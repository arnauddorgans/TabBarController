//
//  TabBarControllerUpdateSource.swift
//  Pods
//
//  Created by Arnaud Dorgans on 18/08/2018.
//

import UIKit

enum TabBarControllerUpdateSource {
    case action
    case update(animated: Bool)
    
    func animateViewController(_ viewController: UIViewController?, in containerController: TabBarContainerController) -> Bool {
        #if os(iOS)
        return animateTabBarSelectedItem() && containerController.viewController.flatMap { fromVC in
            viewController.flatMap { toVC in
                containerController.containerDelegate?.tabBarContainerController(containerController, animationControllerFrom: fromVC, to: toVC)
            }
            } != nil
        #elseif os(tvOS)
        return animateTabBarSelectedItem()
        #endif
    }
    
    func animateTabBarSelectedItem() -> Bool {
        switch self {
        case .action:
            return true
        case .update(animated: let animated):
            return animated
        }
    }
}
