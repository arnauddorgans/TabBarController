//
//  iOS10ViewController.swift
//  TabBarController_Example
//
//  Created by Arnaud Dorgans on 18/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class iOS10ViewController: UIViewController, TabBarChildControllerProtocol {

    @IBOutlet weak var additionalTopInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalBottomInsetConstraint: NSLayoutConstraint!
}
