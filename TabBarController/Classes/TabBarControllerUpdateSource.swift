//
//  TabBarControllerUpdateSource.swift
//  Pods
//
//  Created by Arnaud Dorgans on 18/08/2018.
//

import UIKit

enum TabBarControllerUpdateSource {
    case action
    case update
    
    func animateViewController(_ viewController: UIViewController?, in containerController: TabBarContainerController) -> Bool {
        #if os(iOS)
        return self == .action && containerController.viewController.flatMap { fromVC in
            viewController.flatMap { toVC in
                containerController.containerDelegate?.tabBarContainerController(containerController, animationControllerFrom: fromVC, to: toVC)
            }
            } != nil
        #elseif os(tvOS)
        return true
        #endif
    }
    
    func animateTabBarSelectedItem() -> Bool {
        #if os(iOS)
        return self == .action
        #elseif os(tvOS)
        return true
        #endif
    }
}
