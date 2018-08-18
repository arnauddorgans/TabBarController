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
    private var toggleTabBarGesture: UITapGestureRecognizer!
    
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
        
        self.toggleTabBarGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleToggleGesture(_:)))
        self.toggleTabBarGesture.allowedPressTypes = [NSNumber(integerLiteral: UIPressType.menu.rawValue)]
        self.toggleTabBarGesture.delegate = self
        self.toggleTabBarGesture.isEnabled = self.hideTabBarGesture.isEnabled
        self.addGestureRecognizer(self.toggleTabBarGesture)
    }
    
    func setTabBarHidden(_ hidden: Bool) {
        isTabBarHidden = hidden
        updateTabBarConstraints()
        self.tabBar.setTabBarHidden?(hidden)
    }
    
    // MARK: Constraints
    private func clean() {
        self.subviews.forEach { $0.removeFromSuperview() }
        if let tabBar = tabBar {
            self.removeObserver(tabBar: tabBar)
        }
    }
    private func updateTabBar() {
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
        addObserver(tabBar: tabBar)
        self.addSubview(tabBar)
        tabBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tabBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.tabBar = tabBar
        updateTabBarConstraints()
    }
    
    private func updateTabBarConstraints() {
        let oldConstraints = anchorConstraints
        NSLayoutConstraint.deactivate(oldConstraints)
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
        tabBar.removeConstraints(oldConstraints)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.delegate?.tabBarContainer(self, didShowTabBar: !self.isTabBarHidden)
    }
    
    private func updateInset() {
        guard let tabBar = self.tabBar,
            let tabBarController = self.tabBarController else {
            return
        }
        if self.isTabBarHidden || !(tabBar.needsAdditionalInset ?? tabBar.defaultNeedsAdditionalInset) {
            self.additionalInsets = .zero
        } else {
            self.additionalInsets = {
                let inset = max(0, tabBar.frame.height + (tabBar.additionalInset ?? 0))
                var insets = UIEdgeInsets.zero
                if #available(iOS 11.0, tvOS 11.0, *) {
                    switch self.anchor {
                    case .top:
                        insets.top = max(0, inset - self.safeAreaInsets.top)
                    case .bottom:
                        insets.bottom = max(0, inset - self.safeAreaInsets.bottom)
                    }
                } else {
                    switch self.anchor {
                    case .top:
                        insets.top =  max(0, insets.top + inset)
                    case .bottom:
                        insets.bottom =  max(0, insets.bottom + inset)
                    }
                }
                return insets
            }()
        }
        if #available(iOS 11.0, tvOS 11.0, *) { }
        else {
            let tom = self.anchor == .top ? tabBarController.topLayoutGuide.length : 0
            let bottom = self.anchor == .bottom ? tabBarController.bottomLayoutGuide.length : 0
            tabBar.layoutMargins = UIEdgeInsets(top: tom, left: 0, bottom: bottom, right: 0)
        }
        self.delegate?.tabBarContainer(self, didUpdateAdditionalInsets: self.additionalInsets)
    }
    
    // MARK: iOS
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let tabBar = self.tabBar else {
            return nil
        }
        let point = self.convert(point, to: tabBar)
        return tabBar.hitTest(point, with: event)
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
    
    @objc func handleToggleGesture(_ gesture: UITapGestureRecognizer) {
        self.delegate?.tabBarContainer(self, didHandleShowGesture: self.isTabBarHidden)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard self.isTabBarHidden, self.contains(context.nextFocusedView), !self.contains(context.previouslyFocusedView) else {
            return
        }
        self.delegate?.tabBarContainer(self, didHandleShowGesture: true)
    }
    
    // MARK: Layout
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
    
    // MARK: KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateInset()
    }
    
    func addObserver(tabBar: TabBar) {
        tabBar.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: .new, context: nil)
        tabBar.layer.addObserver(self, forKeyPath: #keyPath(CALayer.position), options: .new, context: nil)
    }
    
    func removeObserver(tabBar: TabBar) {
        tabBar.removeObserver(self, forKeyPath: #keyPath(UIView.bounds))
        tabBar.layer.removeObserver(self, forKeyPath: #keyPath(CALayer.position))
    }
    
    deinit {
        if let tabBar = self.tabBar {
            self.removeObserver(tabBar: tabBar)
        }
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
