//
//  SystemTabBar.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

@IBDesignable open class SystemTabBar: UIView {
    
    public let tabBar = UITabBar()
    public var delegate: TabBarDelegate?
    
    @IBInspectable var barTintColor: UIColor? {
        get { return tabBar.barTintColor }
        set { tabBar.barTintColor = newValue }
    }
    
    @IBInspectable var unselectedItemTintColor: UIColor? {
        get {
            if #available(iOS 10.0, *) {
                return tabBar.unselectedItemTintColor
            }
            return nil
        } set {
            if #available(iOS 10.0, *) {
                tabBar.unselectedItemTintColor = newValue
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        return tabBar.intrinsicContentSize
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
        self.addSubview(tabBar)
        self.layoutMargins = .zero
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        tabBar.frame = self.bounds
    }
    
    override open func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            self.invalidateIntrinsicContentSize()
        }
    }
}

extension SystemTabBar: UITabBarDelegate {
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.delegate?.tabBar(self, didSelect: item)
    }
}

extension SystemTabBar: TabBarProtocol {
    
    @IBInspectable public var selectedItem: UITabBarItem? {
        get { return tabBar.selectedItem }
        set { tabBar.selectedItem = newValue }
    }
    
    @IBInspectable public var isTranslucent: Bool {
        get { return tabBar.isTranslucent }
        set { tabBar.isTranslucent = newValue }
    }
    
    public func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        tabBar.setItems(items, animated: animated)
    }
}
