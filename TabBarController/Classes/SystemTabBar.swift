//
//  SystemTabBar.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

open class SystemTabBar: UIView {
    
    @IBOutlet public weak var tabBar: UITabBar!
    @IBOutlet public weak var delegate: TabBarDelegate?
    
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
        let tabBar = self.tabBar ?? UITabBar()
        tabBar.delegate = self
        if !self.contains(subview: tabBar) {
            tabBar.removeFromSuperview()
            tabBar.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(tabBar)
            tabBar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            tabBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            tabBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            tabBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        self.tabBar = tabBar
    }
    
    public func setTabBarHidden(_ hidden: Bool) {
        #if os(tvOS)
        tabBar.alpha = hidden ? 0.1 : 1
        #endif
    }
    
    // MARK: Layout
    @available(iOS 11.0, tvOS 11.0, *)
    override open func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        tabBar.invalidateIntrinsicContentSize()
    }
    
    // MARK: Focus
    open override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [tabBar]
    }
    
    // iOS 9 support
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
        tabBar.selectedItem = item
    }
}
