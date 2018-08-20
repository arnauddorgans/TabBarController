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
        self.performSegue(withIdentifier: "push", sender: nil)
    }
}

extension iOS9TableViewController {
    
    func tabBarAction() {
        if #available(iOS 11.0, *) {
            self.tableView.setContentOffset(CGPoint(x: -self.tableView.adjustedContentInset.left, y: -self.tableView.adjustedContentInset.top), animated: true)
        } else {
            self.tableView.setContentOffset(CGPoint(x: -self.tableView.contentInset.left, y: -self.tableView.contentInset.top), animated: true)
        }

        guard let item = self.tab.barItem else {
            return
        }
        guard let badgeValue = item.badgeValue.flatMap({ Int($0) }) else {
            item.badgeValue = String(1)
            return
        }
        item.badgeValue = String(badgeValue + 1)
    }
    
    func updateTabBarInsets(_ insets: UIEdgeInsets) {
        self.tableView.contentInset.bottom = insets.bottom
        self.tableView.scrollIndicatorInsets.bottom = insets.bottom
    }
}
