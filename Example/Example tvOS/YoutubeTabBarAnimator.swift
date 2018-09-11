//
//  YoutubeTabBarAnimator.swift
//  TabBarController_Example tvOS
//
//  Created by Arnaud Dorgans on 11/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class YoutubeTabBarAnimator: TabBarAnimator {
    
    private var tabBarConstraints = [NSLayoutConstraint]()
    
    func tabBarInsets(withContext context: TabBarAnimatorContext) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: context.tabBar.frame.width, bottom: 0, right: 0)
    }
    
    func animateTabBar(using context: TabBarAnimatorContext) {
        if tabBarConstraints.isEmpty {
            context.tabBar.translatesAutoresizingMaskIntoConstraints = false
            context.containerView.addSubview(context.tabBar)
            tabBarConstraints.append(context.tabBar.leadingAnchor.constraint(equalTo: context.containerView.leadingAnchor))
            tabBarConstraints.append(context.tabBar.topAnchor.constraint(equalTo: context.containerView.topAnchor))
            tabBarConstraints.append(context.tabBar.bottomAnchor.constraint(equalTo: context.containerView.bottomAnchor))
            NSLayoutConstraint.activate(tabBarConstraints)
        }
    }
}
