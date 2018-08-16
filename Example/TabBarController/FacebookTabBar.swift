//
//  FacebookTabBar.swift
//  TabBarController_Example
//
//  Created by Arnaud Dorgans on 16/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class FacebookTabBarItem: UITabBarItem {
    
    @IBInspectable var selectedTintColor: UIColor = .cyan
}

@IBDesignable class FacebookTabBar: UIView, TabBarProtocol {
    
    private let contentView = UIStackView()
    
    weak var delegate: TabBarDelegate?

    var items: [UITabBarItem]?
    var selectedItem: UITabBarItem? {
        didSet {
            updateSelectedItem()
        }
    }
    
    @IBInspectable var unselectedItemTintColor: UIColor = .gray {
        didSet {
            updateSelectedItem()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    private func sharedInit() {
        self.backgroundColor = .white
        
        contentView.axis = .horizontal
        contentView.distribution = .fillEqually
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        if #available(iOS 11.0, *) {
            contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    }
    
    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        self.items = items
        contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let items = items else {
            return
        }
        (0..<items.count).forEach {
            let button = UIButton()
            button.tag = $0
            button.setImage(items[$0].image, for: .normal)
            button.setImage(items[$0].selectedImage, for: .selected)
            button.addTarget(self, action: #selector(self.didSelect(_:)), for: .touchUpInside)
            contentView.addArrangedSubview(button)
        }
        updateSelectedItem()
    }
    
    private func updateSelectedItem() {
        contentView.arrangedSubviews.forEach {
            guard let button = $0 as? UIButton else {
                return
            }
            button.isSelected = self.items?[$0.tag] == self.selectedItem
            button.tintColor = button.isSelected ? ((self.items?[$0.tag] as? FacebookTabBarItem)?.selectedTintColor ?? self.tintColor) : self.unselectedItemTintColor
        }
    }
    
    @objc func didSelect(_ button: UIButton) {
        guard let item = self.items?[button.tag] else {
            return
        }
        self.delegate?.tabBar(self, didSelect: item)
    }
    
    override func prepareForInterfaceBuilder() {
        let item: (String, String)->UITabBarItem = {
            return UITabBarItem(title: nil,
                                image: UIImage(named: $0, in: Bundle(for: FacebookTabBar.self), compatibleWith: nil),
                                selectedImage: UIImage(named: $1, in: Bundle(for: FacebookTabBar.self), compatibleWith: nil))
        }
        let items = [item("outline-chrome_reader_mode-24px", "twotone-chrome_reader_mode-24px"),
                     item("outline-account_circle-24px", "twotone-account_circle-24px"),
                     item("outline-notifications-24px", "twotone-notifications-24px")]
        self.setItems(items, animated: false)
        self.selectedItem = items.first
    }
}
