//
//  UIView+Helpers.swift
//  Pods
//
//  Created by Arnaud Dorgans on 17/08/2018.
//

import UIKit

extension UIView {
    
    func contains(subview: UIView?) -> Bool {
        guard let subview = subview else {
            return false
        }
        if subview == self {
            return true
        }
        return contains(subview: subview.superview)
    }
    
    func constraints(withView view: UIView) -> [NSLayoutConstraint] {
        return self.constraints.filter { $0.firstItem as? UIView == view || $0.secondItem as? UIView == view }
    }
}
