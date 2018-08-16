//
//  ViewController.swift
//  TabBarController
//
//  Created by Arnoymous on 08/14/2018.
//  Copyright (c) 2018 Arnoymous. All rights reserved.
//

import UIKit
import TabBarController

class ViewController: TabBarController {


}

class ViewControllerTest: UIViewController, TabBarChildControllerProtocol {

    @IBOutlet weak var additionalTopInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalBottomInsetConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func updateAdditionalInset(_ inset: CGFloat) {

    }
}

class HiddenController: ViewControllerTest {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
    }
    
    @IBAction func switchTab(_ sender: Any) {
        guard let controller = self.tab.controller else {
            return
        }
        self.hidesBottomBarWhenPushed = !controller.isTabBarHidden
        controller.setTabBarHidden(self.hidesBottomBarWhenPushed, animated: true)
    }
}
