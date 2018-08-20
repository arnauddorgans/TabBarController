//
//  iOS9ViewController.swift
//  TabBarController_Example
//
//  Created by Arnaud Dorgans on 18/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class iOS9ViewController: UIViewController {

    @IBOutlet weak var tabBarTopInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var tabBarBottomInsetConstraint: NSLayoutConstraint!
    
    @IBAction func toggleTabBar(_ sender: Any) {
        guard let contoller = self.tab.controller else {
            return
        }
        contoller.setTabBarHidden(!contoller.isTabBarHidden, animated: true)
    }
}
