//
//  YoutubeTabBarController.swift
//  TabBarController_Example tvOS
//
//  Created by Arnaud Dorgans on 11/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class YoutubeTabBarController: TabBarController {
    
    let tabBarFocusGuide = UIFocusGuide()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addLayoutGuide(tabBarFocusGuide)
        tabBarFocusGuide.topAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        tabBarFocusGuide.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor).isActive = true
        tabBarFocusGuide.leftAnchor.constraint(equalTo: tabBar.rightAnchor).isActive = true
        tabBarFocusGuide.widthAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        guard let item = context.nextFocusedItem else {
            return
        }
        tabBarFocusGuide.preferredFocusEnvironments = [self.tabBar.contains(item) ? containerView : tabBar]
    }
}

extension YoutubeTabBarController: YoutubeTabBarDelegate {
    
    func youtubeTabBar(_ youtubeTabBar: YoutubeTabBar, didTriggerAction action: YoutubeAction) {
        let searchController = UISearchController(searchResultsController: nil)
        self.present(searchController, animated: true, completion: nil)
    }
}
