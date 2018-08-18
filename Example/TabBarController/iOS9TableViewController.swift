//
//  iOS9TableViewController.swift
//  TabBarController_Example
//
//  Created by Arnaud Dorgans on 18/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class iOS9TableViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contoller = self.tab.controller else {
            return
        }
        contoller.setTabBarHidden(!contoller.isTabBarHidden, animated: true)
    }
}

extension iOS9TableViewController: TabBarChildControllerProtocol {
    
    func tabBarAction() {
        if let badgeValue = self.tabBarItem.badgeValue.flatMap({ Int($0) }) {
            self.tabBarItem.badgeValue = String(badgeValue + 1)
        } else {
            self.tabBarItem.badgeValue = String(1)
        }
    }
    
    func updateAdditionalInsets(_ insets: UIEdgeInsets) {
        self.tableView.contentInset.bottom = insets.bottom
        self.tableView.scrollIndicatorInsets.bottom = insets.bottom
    }
}
