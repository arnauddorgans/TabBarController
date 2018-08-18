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
    
    @IBInspectable var selectedTintColor: UIColor = .blue
}

class FacebookTabBar: UIView, TabBarProtocol {
    
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
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        self.backgroundColor = .white
        
        contentView.axis = .horizontal
        contentView.distribution = .fillEqually
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        if UIDevice.current.userInterfaceIdiom == .tv {
            contentView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else {
            contentView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        if #available(iOS 11.0, *) {
            contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            contentView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        }
    }
    
    func setTabBarHidden(_ hidden: Bool) {
        contentView.arrangedSubviews.forEach {
            $0.transform = hidden ? CGAffineTransform(rotationAngle: .pi/4) : .identity
        }
    }
    
    // MARK: Updates
    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        self.items = items
        contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let items = items else {
            return
        }
        items.forEach {
            guard let button = FacebookTabBarButton(item: $0) else {
                return
            }
            button.addTarget(self, action: #selector(self.didSelect(_:)), for: .touchUpInside)
            contentView.addArrangedSubview(button)
        }
        updateSelectedItem()
    }
    
    private func updateSelectedItem() {
        contentView.arrangedSubviews.forEach {
            guard let button = $0 as? FacebookTabBarButton else {
                return
            }
            button.isSelected = button.item == self.selectedItem
        }
    }
    
    @objc func didSelect(_ button: UIButton) {
        guard let button = button as? FacebookTabBarButton else {
            return
        }
        self.delegate?.tabBar(self, didSelect: button.item)
    }
    
    //MARK: tvOS
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return contentView.arrangedSubviews.sorted(by: { lhs, _ in return (lhs as? UIButton)?.isSelected == true })
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let nextButton = context.nextFocusedView as? FacebookTabBarButton else {
            return
        }
        self.didSelect(nextButton)
    }
}

private class FacebookTabBarButton: UIButton {
    
    let item: FacebookTabBarItem
    
    override var isSelected: Bool {
        didSet {
            update()
        }
    }
    
    init?(item: UITabBarItem) {
        guard let item = item as? FacebookTabBarItem else {
            return nil
        }
        self.item = item
        super.init(frame: .zero)
        addObserver()
        update()
    }
    
    private func update() {
        self.setImage(self.isSelected ? item.selectedImage : item.image, for: .normal)
        self.tintColor = self.isSelected ? item.selectedTintColor : UIColor.gray.withAlphaComponent(0.5)
        self.setTitleColor(self.tintColor, for: .normal)
        self.transform = self.isFocused ? CGAffineTransform(scaleX: 1.5, y: 1.5) : .identity
        self.setTitle(self.item.badgeValue, for: .normal)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations(self.update, completion: nil)
    }
    
    // MARK: KVO
    private func addObserver() {
        item.addObserver(self, forKeyPath: #keyPath(UITabBarItem.badgeValue), options: .new, context: nil)
    }
    
    private func removeObserver() {
        item.removeObserver(self, forKeyPath: #keyPath(UITabBarItem.badgeValue))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        update()
    }
    
    deinit {
        removeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
