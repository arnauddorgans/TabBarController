//
//  TabBarContainer.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

protocol TabBarContainerDelegate: class {
    
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didUpdateAdditionalInsets insets: UIEdgeInsets)
}

class TabBarContainer: UIView {
    
    weak var tabBarController: TabBarController!
    weak var tabBar: TabBar!
    weak var delegate: TabBarContainerDelegate?
    
    private var visibleConstraints = [NSLayoutConstraint]()
    private var hiddenConstraints = [NSLayoutConstraint]()
    
    private (set) var isTabBarHidden: Bool = false

    init(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
        self.delegate = tabBarController
        super.init(frame: .zero)
    }
    
    func setTabBarHidden(_ hidden: Bool) {
        isTabBarHidden = hidden
        updateTabBarConstraints()
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
    
    private func updateSafeArea() {
        if #available(iOS 11.0, *) {
            let inset = max(0, self.tabBar.frame.height - self.tabBar.safeAreaInsets.bottom + (self.tabBar?.additionalInset ?? 0))
            self.delegate?.tabBarContainer(self, didUpdateAdditionalInsets: self.isTabBarHidden ? .zero : UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSafeArea()
    }
    
    override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            updateSafeArea()
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
