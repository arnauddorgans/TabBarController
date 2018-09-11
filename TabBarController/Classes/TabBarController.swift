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
}

open class TabBarController: UIViewController {
    
    @IBOutlet public weak var delegate: TabBarControllerDelegate?
    @IBOutlet public weak var tabBar: TabBar!
    
    private lazy var containerController = TabBarContainerController(delegate: self)
    fileprivate var menuGesture: UITapGestureRecognizer?
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
        set { tabBarAnchor = TabBarAnchor.at(index: newValue) }
    }
    
    #if os(tvOS)
    @IBInspectable var isMenuGesturesEnabled: Bool = true {
        didSet {
            updateFocusGestures()
        }
    }
    #endif
    
    public var containerView: UIView {
        return containerController.view
    }
    
    private var _tabBarAnchor: TabBarAnchor = .default
    public var tabBarAnchor: TabBarAnchor {
        get { return _tabBarAnchor }
        set { self.setTabBarAnchor(newValue) }
    }
    
    private var _isTabBarHidden: Bool = false
    @IBInspectable public var isTabBarHidden: Bool {
        get { return _isTabBarHidden }
        set { self.setTabBarHidden(newValue, animated: false) }
    }
    
    public var selectedViewController: UIViewController? {
        guard let viewControllers = viewControllers, selectedIndex < viewControllers.count else {
            return nil
        }
        return viewControllers[selectedIndex]
    }
    
    private var tabBarAnimator: TabBarAnimator {
        guard let transitionDelegate = tabBar.animator?() else {
            return DefaultTabBarAnimator.shared
        }
        return transitionDelegate
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
        self.view.addSubview(tabBar)
        
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
        
        self.setTabBarHidden(false, animated: false)
        updateFocusGestures()
        addObservers()
    }
    
    // MARK: TabBar
    public func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        self._isTabBarHidden = hidden
        updateTabBar(animated: animated)
    }
    
    private func updateTabBar(animated: Bool) {
        guard self.isViewLoaded else {
            return
        }
        let context = TabBarAnimatorContext(tabBarController: self, animated: animated) { [unowned self] in
            self.tabBar?.setTabBarHidden?(self.isTabBarHidden)
            self.tabBar?.setAnchor?(self.tabBarAnchor)
            self.updateInsets()
        }
        tabBarAnimator.animateTabBar(using: context)
    }
    
    public func setTabBarAnchor(_ anchor: TabBarAnchor) {
        _tabBarAnchor = anchor
        updateTabBar(animated: false)
    }
    
    // MARK: ViewControllers
    public func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        self._viewControllers = viewControllers
        self.updateViewControllers(animated: animated)
    }
    
    private func updateViewControllers(animated: Bool) {
        self._viewControllers = self._viewControllers?.map { TabBarNavigationContainerController(viewController: $0, delegate: self) ?? $0 }
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
        #else
        self.updateInsets(viewController: viewController)
        #endif
    }
    
    private func updateInsets(viewController: UIViewController? = nil) {
        let viewController: TabBarChildControllerProtocol? = viewController ?? containerController.viewController
        let additionalInsets = tabBarAnimator.tabBarInsets(withContext: TabBarAnimatorContext(tabBarController: self))
        viewController?.updateAllTabBarConstraints(additionalInsets)
    }
    
    fileprivate func updateSelectedController(source: TabBarControllerUpdateSource) {
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
    
    // MARK:- Layout
    @available(iOS 11.0, tvOS 11.0, *)
    func updateSafeArea(insets: UIEdgeInsets) {
        self.containerController.additionalSafeAreaInsets = insets
        self.containerController.view.layoutIfNeeded()
    }
    
    // MARK:- Focus
    open override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if self.isTabBarHidden {
            return [containerController.view]
        }
        return [tabBar, containerController.view]
    }
    
    // iOS 9 support
    override open var preferredFocusedView: UIView? {
        return preferredFocusEnvironments.first as? UIView
    }
    
    // MARK: Focus
    func updateFocusGestures() {
        #if os(tvOS)
        guard self.isViewLoaded else {
            return
        }
        if menuGesture == nil {
            let menuGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleMenuGesture(_:)))
            menuGesture.delegate = self
            menuGesture.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
            self.view.addGestureRecognizer(menuGesture)
            self.menuGesture = menuGesture
        }
        menuGesture?.isEnabled = isMenuGesturesEnabled
        #endif
    }
    
    #if os(tvOS)
    @objc func handleMenuGesture(_ gesture: UITapGestureRecognizer) {
        self.setTabBarHidden(false, animated: true)
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    #endif
    
    open override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        guard !self.containerController.isAnimating else {
            return false
        }
        return super.shouldUpdateFocus(in: context)
    }
    
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let tabBar = self.tabBar else {
            return
        }
        if let nextView = context.nextFocusedView, self.isTabBarHidden, tabBar.contains(subview: nextView) {
            coordinator.addCoordinatedAnimations({
                self.setTabBarHidden(false, animated: false)
            }, completion: nil)
            return
        } else if !isTabBarHidden, context.nextFocusedView.flatMap({ tabBar.contains(subview: $0) }) != true {
            coordinator.addCoordinatedAnimations({
                self.setTabBarHidden(true, animated: false)
            }, completion: nil)
        }
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
    
    // MARK: KVO
    private func addObservers() {
        self.tabBar.layer.addObserver(self, forKeyPath: #keyPath(CALayer.position), options: .new, context: nil)
        self.tabBar.layer.addObserver(self, forKeyPath: #keyPath(CALayer.bounds), options: .new, context: nil)
    }
    
    private func removeObservers() {
        self.tabBar.layer.removeObserver(self, forKeyPath: #keyPath(CALayer.position))
        self.tabBar.layer.removeObserver(self, forKeyPath: #keyPath(CALayer.bounds))
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateInsets()
    }
    
    deinit {
        self.removeObservers()
    }
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
        } else {
            #if os(iOS)
            let viewController: TabBarChildControllerProtocol? = self.selectedViewController
            viewController?.tabBarAction?()
            #endif
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
        if #available(iOS 10.0, tvOS 10.0, *) {
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
        transitionCoordinator.animateAlongsideTransition(in: self.tabBar, animation: { [unowned self] context in
            guard let viewController = context.viewController(forKey: .to) else {
                return
            }
            self.update(viewController: viewController)
        }, completion: nil)
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
        guard let viewController = viewController else {
            return
        }
        update(viewController: viewController)
    }
    
    func tabBarContainerController(_ tabBarContainerController: TabBarContainerController, willShow viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        update(viewController: viewController)
    }
}

// MARK:- UITapGestureRecognizer
extension TabBarController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == menuGesture else {
            return true
        }
        return isTabBarHidden
    }
}
