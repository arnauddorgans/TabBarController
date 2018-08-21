//
//  TabBarAnimator.swift
//  Pods
//
//  Created by Arnaud Dorgans on 21/08/2018.
//

import UIKit

@objc public enum TabBarPresentationStyle: Int {
    case shown
    case hidden
}

@objc public class TabBarAnimatorContext: NSObject {
    
    public weak var tabBar: TabBar!
    public weak var tabBarController: TabBarController!
    public weak var containerView: UIView!
    public let presentationStyle: TabBarPresentationStyle
    public let tabBarAnchor: TabBarAnchor
    public let animated: Bool
    private let animations: (()->Void)?
    
    init(tabBarController: TabBarController, animated: Bool = false, animations: (()->Void)? = nil) {
        self.tabBar = tabBarController.tabBar
        self.tabBarController = tabBarController
        self.containerView = tabBarController.view
        self.tabBarAnchor = tabBarController.tabBarAnchor
        self.presentationStyle = tabBarController.isTabBarHidden ? .hidden : .shown
        self.animated = animated
        self.animations = animations
    }
    
    public func animate() {
        animations?()
    }
    
    public func completeTransition(_ didComplete: Bool) {
        animate()
    }
}

@objc public protocol TabBarAnimator: class {

    func tabBarInsets(withContext context: TabBarAnimatorContext) -> UIEdgeInsets
    func animateTabBar(using context: TabBarAnimatorContext)
}

class DefaultTabBarAnimator: TabBarAnimator {
    static let shared = DefaultTabBarAnimator()
    
    private init() {
        
    }
    
    func tabBarInsets(withContext context: TabBarAnimatorContext) -> UIEdgeInsets {
        #if os(tvOS)
        let needsAdditionalInset = false
        #else
        let needsAdditionalInset = true
        #endif
        if context.presentationStyle == .hidden || !needsAdditionalInset {
            return .zero
        } else {
            var insets: UIEdgeInsets = .zero
            let inset: CGFloat = {
                let size = context.tabBarAnchor.isVertical ? context.tabBar.frame.height : context.tabBar.frame.width
                let additionalInset = context.tabBar.additionalInset ?? 0
                return max(0, size + additionalInset)
            }()
            if #available(iOS 11.0, tvOS 11.0, *) {
                switch context.tabBarAnchor {
                case .top:
                    insets.top = max(0, inset - context.containerView.safeAreaInsets.top)
                case .bottom:
                    insets.bottom = max(0, inset - context.containerView.safeAreaInsets.bottom)
                case .left:
                    insets.left = max(0, inset - context.containerView.safeAreaInsets.left)
                case .right:
                    insets.right = max(0, inset - context.containerView.safeAreaInsets.right)
                }
            } else {
                switch context.tabBarAnchor {
                case .top:
                    insets.top = max(0, inset - context.tabBarController.topLayoutGuide.length)
                case .bottom:
                    insets.bottom = max(0, inset - context.tabBarController.bottomLayoutGuide.length)
                case .left:
                    insets.left = inset
                case .right:
                    insets.right = inset
                }
            }
            return insets
        }
    }
    
    func animateTabBar(using context: TabBarAnimatorContext) {
        let constraints = context.containerView.constraints(withView: context.tabBar)

        context.containerView.layoutIfNeeded()
        NSLayoutConstraint.deactivate(constraints)
        context.tabBar.translatesAutoresizingMaskIntoConstraints = false
        switch context.tabBarAnchor.isVertical {
        case true:
            context.tabBar.leadingAnchor.constraint(equalTo: context.containerView.leadingAnchor).isActive = true
            context.tabBar.trailingAnchor.constraint(equalTo: context.containerView.trailingAnchor).isActive = true
        case false:
            context.tabBar.topAnchor.constraint(equalTo: context.containerView.topAnchor).isActive = true
            context.tabBar.bottomAnchor.constraint(equalTo: context.containerView.bottomAnchor).isActive = true
        }
        switch context.tabBarAnchor {
        case .bottom:
            switch context.presentationStyle {
            case .hidden:
                context.tabBar.topAnchor.constraint(equalTo: context.containerView.bottomAnchor).isActive = true
            case .shown:
                context.tabBar.bottomAnchor.constraint(equalTo: context.containerView.bottomAnchor).isActive = true
            }
        case .top:
            switch context.presentationStyle {
            case .hidden:
                context.tabBar.bottomAnchor.constraint(equalTo: context.containerView.topAnchor).isActive = true
            case .shown:
                context.tabBar.topAnchor.constraint(equalTo: context.containerView.topAnchor).isActive = true
            }
        case .left:
            switch context.presentationStyle {
            case .hidden:
                context.tabBar.trailingAnchor.constraint(equalTo: context.containerView.leadingAnchor).isActive = true
            case .shown:
                context.tabBar.leadingAnchor.constraint(equalTo: context.containerView.leadingAnchor).isActive = true
            }
        case .right:
            switch context.presentationStyle {
            case .hidden:
                context.tabBar.leadingAnchor.constraint(equalTo: context.containerView.trailingAnchor).isActive = true
            case .shown:
                context.tabBar.trailingAnchor.constraint(equalTo: context.containerView.trailingAnchor).isActive = true
            }
        }
        context.containerView.removeConstraints(constraints)
        
        func update() {
            context.containerView.layoutIfNeeded()
            context.animate()
        }
        
        if context.animated {
            UIView.animate(withDuration: 0.2, animations: update, completion: context.completeTransition)
        } else {
            update()
            context.completeTransition(true)
        }
    }
}
