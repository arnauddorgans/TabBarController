//
//  TabBarContainer.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

protocol TabBarContainerDelegate: class {
    
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didUpdateAdditionalInsets insets: UIEdgeInsets)
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didShowTabBar show: Bool)
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didHandleShowGesture show: Bool)
}

class TabBarContainer: UIView {
    
    weak var tabBarController: TabBarController!
    weak var tabBar: TabBar!
    weak var delegate: TabBarContainerDelegate?
    
    private (set) var isTabBarHidden: Bool = false
    private var anchorConstraints = [NSLayoutConstraint]()
    private var hideTabBarGesture: UISwipeGestureRecognizer!
    
    var additionalInsets: UIEdgeInsets = .zero
    var anchor: TabBarAnchor = .default {
        didSet {
            updateTabBarConstraints()
        }
    }

    init(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
        self.delegate = tabBarController
        super.init(frame: .zero)
        self.hideTabBarGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleHideGesture(_:)))
        self.hideTabBarGesture.delegate = self
        self.hideTabBarGesture.isEnabled = UIDevice.current.userInterfaceIdiom == .tv
        self.addGestureRecognizer(self.hideTabBarGesture)
    }
    
    func setTabBarHidden(_ hidden: Bool) {
        isTabBarHidden = hidden
        updateTabBarConstraints()
        self.tabBar.setTabBarHidden?(hidden)
    }
    
    // MARK: TabBar Constraints
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
        
        self.tabBar = tabBar
        updateTabBarConstraints()
    }
    
    private func updateTabBarConstraints() {
        NSLayoutConstraint.deactivate(anchorConstraints)
        anchorConstraints.removeAll()
        
        guard let tabBar = self.tabBar else {
            return
        }
        switch self.anchor {
        case .top:
            if isTabBarHidden {
                anchorConstraints = [tabBar.bottomAnchor.constraint(equalTo: self.topAnchor)]
            } else {
                anchorConstraints = [tabBar.topAnchor.constraint(equalTo: self.topAnchor)]
            }
            hideTabBarGesture.direction = .down
        case .bottom:
            if isTabBarHidden {
                anchorConstraints = [tabBar.topAnchor.constraint(equalTo: self.bottomAnchor)]
            } else {
                anchorConstraints = [tabBar.bottomAnchor.constraint(equalTo: self.bottomAnchor)]
            }
            hideTabBarGesture.direction = .up
        }
        NSLayoutConstraint.activate(anchorConstraints)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.delegate?.tabBarContainer(self, didShowTabBar: !self.isTabBarHidden)
    }
    
    private func updateInset() {
        if self.isTabBarHidden || !(self.tabBar.needsAdditionalInset ?? self.tabBar.defaultNeedsAdditionalInset) {
            self.additionalInsets = .zero
        } else {
            self.additionalInsets = {
                var inset = max(0, self.tabBar.frame.height + (self.tabBar?.additionalInset ?? 0))
                if #available(iOS 11.0, tvOS 11.0, *) {
                    inset = max(0, inset - (self.anchor == .bottom ? self.tabBar.safeAreaInsets.bottom : self.tabBar.safeAreaInsets.top))
                }
                return UIEdgeInsets(top: self.anchor == .bottom ? 0 : inset, left: 0, bottom: self.anchor != .bottom ? 0 : inset, right: 0)
            }()
        }
        self.delegate?.tabBarContainer(self, didUpdateAdditionalInsets: self.additionalInsets)
    }

    // MARK: tvOS
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [tabBar]
    }
    
    @objc func handleHideGesture(_ gesture: UISwipeGestureRecognizer) {
        guard !self.isTabBarHidden else {
            return
        }
        self.delegate?.tabBarContainer(self, didHandleShowGesture: false)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard self.isTabBarHidden, self.contains(context.nextFocusedView) else {
            return
        }
        self.delegate?.tabBarContainer(self, didHandleShowGesture: true)
    }
    
    // MARK: iOS
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let tabBar = tabBar else {
            return nil
        }
        let point = self.convert(point, to: tabBar)
        return tabBar.hitTest(point, with: event)
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateInset()
    }
    
    override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, tvOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            updateInset()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateTabBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBarContainer: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
