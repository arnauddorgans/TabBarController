//
//  FacebookTabBarTransition.swift
//  TabBarController_Example
//
//  Created by Arnaud Dorgans on 17/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class FacebookTabBarTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isNext: Bool
    
    init(isNext: Bool) {
        self.isNext = isNext
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        let padding = finalFrame.width * 1/3
        containerView.addSubview(toView)
        toView.alpha = 0
        
        if isNext {
            toView.frame = CGRect(x: finalFrame.minX + padding, y: finalFrame.origin.y, width: finalFrame.width, height: finalFrame.height)
        } else {
            toView.frame = CGRect(x: finalFrame.minX - padding, y: finalFrame.origin.y, width: finalFrame.width, height: finalFrame.height)
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toView.frame = finalFrame
            toView.alpha = 1
            if self.isNext {
                fromView.frame = CGRect(x: initialFrame.minX - padding, y: initialFrame.origin.y, width: initialFrame.width, height: initialFrame.height)
            } else {
                fromView.frame = CGRect(x: initialFrame.minX + padding, y: initialFrame.origin.y, width: initialFrame.width, height: initialFrame.height)
            }
        }, completion: {
            transitionContext.completeTransition($0)
            fromView.frame = initialFrame
        })
    }
}
