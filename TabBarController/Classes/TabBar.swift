//
//  TabBar.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

public typealias TabBar = UIView & TabBarProtocol

@objc public enum TabBarAnchor: Int {
    case top
    case bottom
    
    static let all = [top, bottom]
    
    public static let `default`: TabBarAnchor = {
        #if os(tvOS)
        return .top
        #else
        return .bottom
        #endif
    }()
}

@objc public protocol TabBarProtocol: NSObjectProtocol {
    
    weak var delegate: TabBarDelegate? { get set }
    @objc optional var additionalInset: CGFloat { get }
    @objc optional var needsAdditionalInset: Bool { get }
    
    func setSelectedItem(_ item: UITabBarItem?, animated: Bool)
    func setItems(_ items: [UITabBarItem]?, animated: Bool)
    @objc optional func setTabBarHidden(_ hidden: Bool)
    @objc optional func setAnchor(_ anchor: TabBarAnchor)
}

extension TabBarProtocol {
    
    var defaultNeedsAdditionalInset: Bool {
        #if os(tvOS)
        return false
        #else
        return true
        #endif
    }
}

@objc public protocol TabBarDelegate: NSObjectProtocol {
    
    func tabBar(_ tabBar: TabBar, didSelect item: UITabBarItem)
}
