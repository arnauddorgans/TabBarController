//
//  UIView+Helpers.swift
//  Pods
//
//  Created by Arnaud Dorgans on 17/08/2018.
//

import UIKit

extension UIView {
    
    func contains(_ view: UIView?) -> Bool {
        guard let view = view else {
            return false
        }
        if view == self {
            return true
        }
        return contains(view.superview)
    }
}
