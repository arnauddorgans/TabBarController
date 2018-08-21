//
//  TabBarAnchor.swift
//  Pods
//
//  Created by Arnaud Dorgans on 21/08/2018.
//

import UIKit

@objc public enum TabBarAnchor: Int {
    case top
    case bottom
    case left
    case right
    
    static let all = [top, bottom, left, right]
    
    static func at(index: Int) -> TabBarAnchor {
        return all[abs(index) % all.count]
    }
    
    public static let `default`: TabBarAnchor = {
        #if os(tvOS)
        return .top
        #else
        return .bottom
        #endif
    }()
    
    public var isHorizontal: Bool {
        switch self {
        case .left, .right:
            return true
        default:
            return false
        }
    }
    
    public var isVertical: Bool {
        switch self {
        case .top, .bottom:
            return true
        default:
            return false
        }
    }
}
