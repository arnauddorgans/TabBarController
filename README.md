# TabBarController

[![CI Status](https://img.shields.io/travis/Arnoymous/TabBarController.svg?style=flat)](https://travis-ci.org/Arnoymous/TabBarController)
[![Version](https://img.shields.io/cocoapods/v/TabBarController.svg?style=flat)](https://cocoapods.org/pods/TabBarController)
[![License](https://img.shields.io/cocoapods/l/TabBarController.svg?style=flat)](https://cocoapods.org/pods/TabBarController)
[![Platform](https://img.shields.io/cocoapods/p/TabBarController.svg?style=flat)](https://cocoapods.org/pods/TabBarController)

How boring it is, when you discover on the latest update of your Zeplin's project that your designer made a tabBar, that didn't fit in 49px height ?
Or maybe just an advanced design of tabBar that can't be a subclass of UITabBar ?
This moment when you know that you'll be constraint to imagine a custom hierarchy for your app just for a designer.. 😜

TabBarController act like a UITabBarController that allow you to provide any custom view and use it as tabBar, you can even set a custom anchor for your tabBar, you want a top tabBar ? or maybe just a bottom tabBar on tvOS ?
Well.. you can easily do all of thoses things with exactly 0 line of code, directly from you storyboard (or programmatically, if your not a storyboard's big fan 😉)

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/001.gif" width="250" height="540"><img src="https://github.com/arnauddorgans/TabBarController/blob/master/004.gif" width="520">

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

You can set up a TabBarController directly from your storyboard, to do it :

- Add a UIViewController on your storyboard and subclass it with TabBarController
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/storyboard0.png" width="250">

- Change the storyboardSeguesCount attribute
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/storyboard1.png" width="250">

- Add custom segues that inherit from TabBarSegue
- For each of your segues you have to set an identifier that start with 'tab' and end with its index in TabBar
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/storyboard2.jpg" width="250">

Example: if you want 4 viewControllers in your tab, you have to set storyboardSeguesCount to 4, and name your custom segues tab0, tab1, tab2 and tab3

Et Voila !

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/storyboard3.png" width="500">

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

If you want to handle the scroll to top functionallity like system's UITabBarController when you tap on selected tab in tabBar

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
self.tab.barItem // return the tabBarItem of self parent in TabBarController
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

Create a UIView class and make it inherit from TabBarProtocol

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

### Storyboard

Link tabBar outlet from your TabBarController to your custom tabBar in storyboard
<img src="https://github.com/arnauddorgans/TabBarController/blob/master/storyboardtab.jpg" width="500">

### Programmatically

```swift
let tabBar = YourTabBar()
let tabBarController = TabBarController(viewControllers: [...], tabBar: tabBar)
```

## Advanced Customization

### Anchor

TabBarController support two anchor for TabBar:

- top: tvOS style
- bottom: iOS style

#### Storyboard

Set the tabBarAnchorIndex attribute of your TabBarController (0: top, 1: bottom)

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/storyboardAnchor.png" width="250">

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
    var needsAdditionalInset: Bool { return true } // return false if you don't want tabBarController to add inset below tabBar (like tvOS)

    func setAnchor(_ anchor: TabBarAnchor) {
        // Update view
    }
    
    func setTabBarHidden(_ hidden: Bool) {
        // Update view
    }
}
```

## Prior iOS 11 support

TabBarController is optimized for iOS 11 and safeArea, if you want support iOS 9 & 10 you need to use additional insets.
This library provide different ways to do so.

### TabBar Top/Bottom Inset Constraint

The TabBarChildControllerProtocol provide two optionals property that allow you to manage tabBar insets easily :
```swift 
var tabBarTopInsetConstraint: NSLayoutConstraint!
var tabBarBottomInsetConstraint: NSLayoutConstraint!
```

Since UIViewController inherit from TabBarChildControllerProtocol, just add these properties in your class (use IBOutlet if you want to use them Interface Builder)

<img src="https://github.com/arnauddorgans/TabBarController/blob/master/constraint.jpg" width="500">

*See iOS9ViewController.swift example*

### Update TabBar Insets

If you want to add inset on your UIScrollView instead of directly update its frame, you can handle it using this method:
```swift
func updateTabBarInsets(_ insets: UIEdgeInsets)
```
*See iOS9TableViewController.swift example*

## Author

Arnoymous, arnaud.dorgans@gmail.com

## License

TabBarController is available under the MIT license. See the LICENSE file for more info.
