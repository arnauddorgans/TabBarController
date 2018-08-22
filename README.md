# TabBarController

[![CI Status](https://img.shields.io/travis/Arnoymous/TabBarController.svg?style=flat)](https://travis-ci.org/Arnoymous/TabBarController)
[![Version](https://img.shields.io/cocoapods/v/TabBarController.svg?style=flat)](https://cocoapods.org/pods/TabBarController)
[![License](https://img.shields.io/cocoapods/l/TabBarController.svg?style=flat)](https://cocoapods.org/pods/TabBarController)
[![Platform](https://img.shields.io/cocoapods/p/TabBarController.svg?style=flat)](https://cocoapods.org/pods/TabBarController)

How boring is it when you discover on the latest update of your Zeplin’s project that you designer made a TabBar that doesn’t fit in 49px in height? 
Or when you discover that they only made an advanced design of TabBar that can’t be a subclass of UITabBar? We all know that moment when you have to imagine a custom hierarchy for your app just for a designer… 😜

TabBarController acts like a UITabBarController that allows you to customize TabBar, transforms and animations. 
You can even set a custom anchor for your TabBar. You want a top tabBar? Or just a bottom TabBar on tvOS? Well… you can easily do all these things with exactly 0 line of code, directly from your storyboard (or programmatically, if you’re not a big fan of storyboards 😉)

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/001.gif" width="250" height="540"><img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/004.gif" width="520">

## Requirements

Xcode 9.0
Swift 4.0

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

TabBarController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TabBarController'
```

## Usage


### Storyboard

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/storyboard3.png" width="500">

You can set up a TabBarController directly from your storyboard, to do it :

- Add a UIViewController on your storyboard and make it inherits from TabBarController
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/storyboard0.png" width="250">

- Change the TabBarController's storyboardSeguesCount attribute
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/storyboard1.png" width="250">

- Add custom segues that inherit from TabBarSegue
- For each of your segues you have to set an identifier that starts with 'tab' and ends with its index in TabBar
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/storyboard2.jpg" width="250">

Example: if you want 4 viewControllers in your tab, you have to set storyboardSeguesCount to 4, and name your custom segues tab0, tab1, tab2 and tab3

Et Voila !

### Programmatically

```swift
let tabBarController = TabBarController(viewControllers: [...])
self.present(tabBarController, animated: true, completion: nil) // present it, set it as rootViewController, what ever..
```

### Hide TabBar

```swift
self.hidesBottomBarWhenPushed = true // automatically hide tabBar when pushed

self.tab.controller?.setTabBarHidden(true, animated: true) // manually hide tabBar, animated or not
```

*See iOS9ViewController.swift example*

### Scroll To Top

If you want to handle the scroll to top functionallity like system's UITabBarController when you tap on selected tab in TabBar

```swift
func tabBarAction() {
    //
    self.tableView.setContentOffset(.zero, animated: true)
}
```

*See iOS9TableViewController.swift example*

### Tab

TabBarController provide extensions for UIViewController:
```swift
self.tab.controller // return the tabBarController of self
self.tab.bar // return the tabBar of self.tab.controller
self.tab.barItem // return the tabBarItem of self's parent in TabBarController
self.tab.navigationController /* In case of the root view controller of your controller's tab is a UINavigationController, TabBarController add it in private parent controller. 
Using self.tab.navigationController on this private parent controller (via self.tab.controller?.viewControllers for example) return your navigationController*/
self.tab.isNavigationController // return true if self.tab.navigationController != nil
```

### NavigationController

TabBarController allows you to use UINavigationController as root view controller of each tab of your tabBarController,
But to do so, it add it in a private parent controller and set its delegate to the TabBarController
If you want to use custom delegate for your UINavigationController please redirect thoses events to the tabBarController, otherwise hidesBottomBarWhenPushed and other displays functionalities will not work.
```swift
func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    //
    navigationController.tab.controller?.navigationController(navigationController, willShow: viewController, animated: animated)
}

func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    //
    navigationController.tab.controller?.navigationController(navigationController, didShow: viewController, animated: animated)
}
```

## Customization

Create a UIView class and make it inherits from TabBarProtocol

```swift
import TabBarController

class YourTabBar: UIView, TabBarProtocol {
    
    weak var delegate: TabBarDelegate?
    
    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        // Update view
    }
    
    func setSelectedItem(_ item: UITabBarItem?, animated: Bool) {
        // Update view
    }
}
```

*See SpringboardTabBar.swift example*

### Storyboard

Link the tabBar outlet from your TabBarController to your custom tabBar in storyboard
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/storyboardtab.jpg" width="500">

### Programmatically

```swift
let tabBar = YourTabBar()
let tabBarController = TabBarController(viewControllers: [...], tabBar: tabBar)
```

## Advanced Customization

### Anchor

TabBarController supports four anchors for TabBar:

- top: tvOS style
- bottom: iOS style
- left
- right


#### Storyboard

Set the tabBarAnchorIndex attribute of your TabBarController (0: top, 1: bottom, 2: left, 3: right)

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/storyboardAnchor.png" width="250">

#### Programmatically

```swift
let tabBar = YourTabBar()
let anchor: TabBarAnchor = .top
let tabBarController = TabBarController(viewControllers: [...], tabBar: tabBar, anchor: anchor)
```

### TabBar

```swift
class YourTabBar: UIView, TabBarProtocol {

    var additionalInset: CGFloat { return 0 } // positive or negative value

    func setAnchor(_ anchor: TabBarAnchor) {
        // Update view
    }
    
    func setTabBarHidden(_ hidden: Bool) {
        // Update view
    }
}
```

### Animator

TabBarProtocol provides optionnal method that allows you to customize animations and frames for your TabBar.
```swift
class YourTabBar: UIView, TabBarProtocol {

    func animator() -> TabBarAnimator? {
        return YourTabBarAnimator()
    }
}

class YourTabBarAnimator: TabBarAnimator {

    func tabBarInsets(withContext context: TabBarAnimatorContext) -> UIEdgeInsets {
        // return additional insets below your TabBar
    }

    func animateTabBar(using context: TabBarAnimatorContext) {
        // Animate and update frame of the TabBar
        UIView.animate(duration: 0.3, animations: {
            context.tabBar.frame = finalFrame // update frame
            context.animate() // animate insets updates
        }, completion: context.completeTransition) // call completeTransition
    }   
}
```

*See TabBarAnimator.swift*

### Transition

If you want to use custom animations on your TabBarController you have to make it inherits from TabBarControllerDelegate

```swift
extension YourTabBarController: TabBarControllerDelegate {

    func tabBarController(_ tabBarController: TabBarController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // return your custom UIViewControllerAnimatedTransitioning
    }
}
```

*See SpringboardTabBarController.swift example*

## Prior iOS 11 support

TabBarController is optimized for iOS 11 and safeArea, if you want support iOS 9 & 10 you need to use additional insets.
This library provides different ways to do so.

### TabBar Top/Bottom Inset Constraint

The TabBarChildControllerProtocol provides two optional properties that allows you to manage TabBar insets easily :
```swift 
var tabBarTopInsetConstraint: NSLayoutConstraint!
var tabBarBottomInsetConstraint: NSLayoutConstraint!
var tabBarLeadingInsetConstraint: NSLayoutConstraint!
var tabBarTrailingInsetConstraint: NSLayoutConstraint!
```

Since UIViewController inherits from TabBarChildControllerProtocol, just add these properties in your class (use IBOutlet if you want to use them Interface Builder)

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/Images/constraint.jpg" width="500">

*See iOS9ViewController.swift example*

### Update TabBar Insets

If you want to add insets on your UIScrollView instead of directly update its frame, you can handle it using this method:
```swift
func updateTabBarInsets(_ insets: UIEdgeInsets) {
    self.tableView.contentInset.bottom = insets.bottom
    self.tableView.scrollIndicatorInsets.bottom = insets.bottom
}
```
*See iOS9TableViewController.swift example*

## Author

Arnaud Dorgans, arnaud.dorgans@gmail.com

## License

TabBarController is available under the MIT license. See the LICENSE file for more info.
