//
//  TabBarContainer.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

protocol TabBarContainerDelegate: class {
    
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didUpdateAdditionalInset inset: CGFloat)
}

class TabBarContainer: UIView {
    
    weak var tabBarController: TabBarController!
    weak var tabBar: TabBar!
    weak var delegate: TabBarContainerDelegate?
    
    private var visibleConstraints = [NSLayoutConstraint]()
    private var hiddenConstraints = [NSLayoutConstraint]()
    
    private (set) var isTabBarHidden: Bool = false
    
    var additionalInset: CGFloat = 0

    init(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
        self.delegate = tabBarController
        super.init(frame: .zero)
    }
    
    func setTabBarHidden(_ hidden: Bool) {
        isTabBarHidden = hidden
        updateTabBarConstraints()
        self.tabBar.setTabBarHidden?(hidden)
    }
    
    private func updateTabBar() {
        func clean() {
            self.subviews.forEach { $0.removeFromSuperview() }
        }
        guard let tabBarController = tabBarController,
            let tabBar = tabBarController.tabBar else {
            clean()
            return
        }
        guard !tabBar.isEqual(self.tabBar) else {
            return
        }
        clean()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tabBar)
        tabBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tabBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: tabBar.heightAnchor).isActive = true
        
        self.tabBar = tabBar
        self.visibleConstraints = [tabBar.bottomAnchor.constraint(equalTo: self.bottomAnchor)]
        self.hiddenConstraints = [tabBar.topAnchor.constraint(equalTo: self.bottomAnchor)]
        updateTabBarConstraints()
    }
    
    private func updateTabBarConstraints() {
        self.visibleConstraints.forEach { $0.isActive = !self.isTabBarHidden }
        self.hiddenConstraints.forEach { $0.isActive = self.isTabBarHidden }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateTabBar()
    }
    
    private func updateInset() {
        if self.isTabBarHidden {
            self.additionalInset = 0
        } else {
            var inset = max(0, self.tabBar.frame.height + (self.tabBar?.additionalInset ?? 0))
            if #available(iOS 11.0, *) {
                inset = max(0, inset - self.tabBar.safeAreaInsets.bottom)
            }
            self.additionalInset = inset
        }
        self.delegate?.tabBarContainer(self, didUpdateAdditionalInset: self.additionalInset)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateInset()
    }
    
    override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            updateInset()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let tabBar = tabBar else {
            return nil
        }
        let point = self.convert(point, to: tabBar)
        return tabBar.hitTest(point, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
