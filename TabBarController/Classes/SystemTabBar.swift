//
//  SystemTabBar.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

@IBDesignable open class SystemTabBar: UIView {
    
    public let tabBar = UITabBar()
    public weak var delegate: TabBarDelegate?
    
    public var items: [UITabBarItem]? {
        return tabBar.items
    }
    
    public var selectedItem: UITabBarItem? {
        get { return tabBar.selectedItem }
        set { tabBar.selectedItem = newValue }
    }
    
    @IBInspectable public var isTranslucent: Bool {
        get { return tabBar.isTranslucent }
        set { tabBar.isTranslucent = newValue }
    }
        
    @IBInspectable var barTintColor: UIColor? {
        get { return tabBar.barTintColor }
        set { tabBar.barTintColor = newValue }
    }
    
    @IBInspectable var unselectedItemTintColor: UIColor? {
        get {
            if #available(iOS 10.0, tvOS 10.0, *) {
                return tabBar.unselectedItemTintColor
            }
            return nil
        } set {
            if #available(iOS 10.0, tvOS 10.0, *) {
                tabBar.unselectedItemTintColor = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    private func sharedInit() {
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tabBar)
        tabBar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tabBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tabBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tabBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    public func setTabBarHidden(_ hidden: Bool) {
        #if os(tvOS)
        tabBar.alpha = hidden ? 0.1 : 1
        #endif
    }
    
    // MARK: Layout
    override open func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, tvOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            tabBar.invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: InterfaceBuilder
    open override func prepareForInterfaceBuilder() {
        let items = [UITabBarItem(tabBarSystemItem: .favorites, tag: 0),
                     UITabBarItem(tabBarSystemItem: .recents, tag: 0),
                     UITabBarItem(tabBarSystemItem: .contacts, tag: 0),
                     UITabBarItem(tabBarSystemItem: .search, tag: 0)]
        self.setItems(items, animated: false)
        self.selectedItem = items.first
    }
    
    // MARK: Focus
    open override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [tabBar]
    }
    
    override open var preferredFocusedView: UIView? {
        return preferredFocusEnvironments.first as? UIView
    }
}

extension SystemTabBar: UITabBarDelegate {
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.delegate?.tabBar(self, didSelect: item)
    }
}

extension SystemTabBar: TabBarProtocol {
    
    public func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        tabBar.setItems(items, animated: animated)
    }
    
    public func setSelectedItem(_ item: UITabBarItem?, animated: Bool) {
        self.selectedItem = item
    }
}
