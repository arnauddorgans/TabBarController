//
//  TabBar.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

public typealias TabBar = UIView & TabBarProtocol

@objc public protocol TabBarProtocol: NSObjectProtocol {
    
    weak var delegate: TabBarDelegate? { get set }
    var selectedItem: UITabBarItem? { get set }
    @objc optional var additionalInset: CGFloat { get }
    
    func setItems(_ items: [UITabBarItem]?, animated: Bool)
    @objc optional func setTabBarHidden(_ hidden: Bool)
}

@objc public protocol TabBarDelegate: NSObjectProtocol {
    
    func tabBar(_ tabBar: TabBar, didSelect item: UITabBarItem)
}
