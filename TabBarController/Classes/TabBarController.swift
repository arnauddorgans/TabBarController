//
//  TabBarController.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 14/08/2018.
//

import UIKit

@objc public protocol TabBarControllerDelegate: class {
    @objc optional func tabBarController(_ tabBarController: TabBarController, shouldSelect viewController: UIViewController) -> Bool
    @objc optional func tabBarController(_ tabBarController: TabBarController, didSelect viewController: UIViewController)
    @objc optional func tabBarController(_ tabBarController: TabBarController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    @objc optional func tabBarController(_ tabBarController: TabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    @objc optional func tabBarController(_ tabBarController: TabBarController, animateTabBar animations: ()->Void)
}

open class TabBarController: UIViewController {
    
    @IBOutlet public weak var delegate: TabBarControllerDelegate?
    @IBOutlet public weak var tabBar: TabBar!
    
    private lazy var containerController = TabBarContainerController(delegate: self)
    private lazy var tabBarContainer = TabBarContainer(tabBarController: self, delegate: self)
    private let storyboardSegueIdentifierPrefix = "tab"
    
    private var _viewControllers: [UIViewController]?
    public var viewControllers: [UIViewController]? {
        get { return _viewControllers }
        set {
            _viewControllers = newValue
            updateViewControllers(animated: false)
        }
    }
    
    private var _selectedIndex: Int = 0
    public var selectedIndex: Int {
        get { return _selectedIndex }
        set {
            _selectedIndex = newValue
            updateSelectedController(source: .action)
        }
    }
    
    @IBInspectable var storyboardSeguesCount: Int = 0
    
    @IBInspectable var tabBarAnchorIndex: Int {
        get { return TabBarAnchor.all.index(of: tabBarAnchor)! }
        set { tabBarAnchor = TabBarAnchor.all[newValue % 2 == 0 ? 0 : 1] }
    }
    
    public var tabBarAnchor: TabBarAnchor {
        get { return tabBarContainer.anchor }
        set { tabBarContainer.anchor = newValue }
    }
    
    public var isTabBarHidden: Bool {
        return tabBarContainer.isTabBarHidden
    }
    
    public var selectedViewController: UIViewController? {
        guard let viewControllers = viewControllers, selectedIndex < viewControllers.count else {
            return nil
        }
        return viewControllers[selectedIndex]
    }
    
    public convenience init(viewControllers: [UIViewController]?, tabBar: TabBar? = nil, anchor: TabBarAnchor = .default) {
        self.init(nibName: nil, bundle: nil)
        self.tabBar = tabBar
        self.tabBarAnchor = anchor
        self.setViewControllers(viewControllers, animated: false)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBar ?? SystemTabBar()
        self.tabBar = tabBar
        self.tabBar?.delegate = self
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tabBarContainer)
        tabBarContainer.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tabBarContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tabBarContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tabBarContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        addStoryboardSegues()
        
        containerController.willMove(toParentViewController: self)
        containerController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(containerController.view, at: 0)
        containerController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        containerController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        containerController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.addChildViewController(containerController)
        containerController.didMove(toParentViewController: self)
    }
    
    // MARK: TabBar
    public func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        func update() {
            self.tabBarContainer.setTabBarHidden(hidden)
        }
        if animated {
            guard self.delegate?.tabBarController?(self, animateTabBar: update) == nil else {
                return
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: update, completion: nil)
        } else {
            update()
        }
    }
    
    // MARK: ViewControllers
    public func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        self._viewControllers = viewControllers
        self.updateViewControllers(animated: animated)
    }
    
    private func updateViewControllers(animated: Bool) {
        self._viewControllers = self._viewControllers?.map { TabBarNavigationContainerController(viewController: $0, tabBarController: self) ?? $0 }
        self.tabBar?.setItems(viewControllers.flatMap { $0.map { $0.tabBarItem } }, animated: animated)
        updateSelectedController(source: .update(animated: animated))
    }
    
    open func update(viewController: UIViewController) {
        #if os(iOS)
        self.setNeedsStatusBarAppearanceUpdate()
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
        self.setTabBarHidden(viewController.hidesBottomBarWhenPushed, animated: false)
        #endif
    }
    
    private func updateInsets(viewController: UIViewController? = nil) {
        let viewController: TabBarChildControllerProtocol? = viewController ?? containerController.viewController
        viewController?.updateAllTabBarConstraints(tabBarContainer.additionalInsets)
    }
    
    private func updateSelectedController(source: TabBarControllerUpdateSource) {
        guard let viewControllers = self.viewControllers, !viewControllers.isEmpty else {
            containerController.setViewController(nil, source: source)
            self._selectedIndex = 0
            return
        }
        self._selectedIndex = max(0, min(viewControllers.count - 1, selectedIndex))
        containerController.setViewController(viewControllers[selectedIndex], source: source)
        self.tabBar?.setSelectedItem(self.selectedViewController?.tabBarItem, animated: source.animateTabBarSelectedItem())
    }
    
    // MARK:- StoryboardSegue
    private func addStoryboardSegues() {
        for i in 0..<storyboardSeguesCount {
            self.performSegue(withIdentifier: storyboardSegueIdentifierPrefix + String(i), sender: self)
        }
    }
    
    // MARK:- SafeArea
    func updateSafeArea(insets: UIEdgeInsets) {
        if #available(iOS 11.0, tvOS 11.0, *) {
            self.containerController.additionalSafeAreaInsets = insets
            self.containerController.view.layoutIfNeeded()
        }
    }
    
    // MARK:- Focus
    open override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if self.isTabBarHidden {
            return [containerController.view]
        }
        return [tabBarContainer, containerController.view]
    }
    
    override open var preferredFocusedView: UIView? {
        return preferredFocusEnvironments.first as? UIView
    }
    
    open override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        guard !self.containerController.isAnimating else {
            return false
        }
        return super.shouldUpdateFocus(in: context)
    }
    
    // MARK:- ChildViewController
    #if os(iOS)
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return containerController
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return containerController
    }
    
    open override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return containerController
    }
    #endif
}

// MARK:- TabBarDelegate
extension TabBarController: TabBarDelegate {
    
    public func tabBar(_ tabBar: TabBar, didSelect item: UITabBarItem) {
        guard let index = self.viewControllers?.index(where: { $0.tabBarItem == item }),
            let controller = self.viewControllers?[index] else {
            return
        }
        guard self.delegate?.tabBarController?(self, shouldSelect: controller) != false else {
            updateSelectedController(source: .update(animated: false))
            return
        }
        if index != self.selectedIndex {
            self.selectedIndex = index
            guard let selectedViewController = self.selectedViewController else {
                return
            }
            self.delegate?.tabBarController?(self, didSelect: selectedViewController)
        } else if UIDevice.current.userInterfaceIdiom != .tv {
            let viewController: TabBarChildControllerProtocol? = self.selectedViewController
            viewController?.tabBarAction?()
        }
    }
}

// MARK:- UINavigationControllerDelegate
extension TabBarController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        update(navigationController: navigationController, viewController: viewController, animated: animated)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        update(navigationController: navigationController, viewController: viewController, animated: animated)
    }
    
    private func update(navigationController: UINavigationController, viewController: UIViewController, animated: Bool) {
        guard let transitionCoordinator = navigationController.transitionCoordinator, animated else {
            self.update(viewController: viewController)
            return
        }
        if #available(iOS 10.0, *) {
            transitionCoordinator.notifyWhenInteractionChanges { [unowned self] context in
                guard let viewController = context.viewController(forKey: .from), context.isCancelled else {
                    return
                }
                self.update(viewController: viewController)
            }
        } else {
            transitionCoordinator.notifyWhenInteractionEnds { [unowned self] context in
                guard let viewController = context.viewController(forKey: .from), context.isCancelled else {
                    return
                }
                self.update(viewController: viewController)
            }
        }
        transitionCoordinator.animateAlongsideTransition(in: tabBarContainer, animation: { [unowned self] context in
            guard let viewController = context.viewController(forKey: .to) else {
                return
            }
            self.update(viewController: viewController)
        }, completion: nil)
    }
}

// MARK:- TabBarContainerDelegate
extension TabBarController: TabBarContainerDelegate {
    
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didShowTabBar show: Bool) {
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didHandleShowGesture show: Bool) {
        self.setTabBarHidden(!show, animated: true)
    }
    
    func tabBarContainer(_ tabBarContainer: TabBarContainer, didUpdateAdditionalInsets insets: UIEdgeInsets) {
        updateInsets()
    }
}

// MARK:- TabBarContainerControllerDelegate
extension TabBarController: TabBarContainerControllerDelegate {
    
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.delegate?.tabBarController?(self, interactionControllerFor: animationController)
    }
    
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.delegate?.tabBarController?(self, animationControllerFrom: fromVC, to: toVC)
    }
    
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, didShow viewController: UIViewController?) {
        updateInsets(viewController: viewController)
    }
    
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, willShow viewController: UIViewController?) {
        updateInsets(viewController: viewController)
    }
}
