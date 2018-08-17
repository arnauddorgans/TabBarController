//
//  TabBarSegue.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 16/08/2018.
//

import UIKit

public class TabBarSegue: UIStoryboardSegue {
    
    public override func perform() {
        guard let source = self.source as? TabBarController else {
            return
        }
        if source.viewControllers == nil {
            source.viewControllers = [self.destination]
        } else {
            source.viewControllers?.append(self.destination)
        }
    }
}
