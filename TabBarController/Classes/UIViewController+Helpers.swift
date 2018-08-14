//
//  UIViewController+Helpers.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

extension UIViewController {
    
    public var tab: Tab {
        return Tab(base: self)
    }
}
