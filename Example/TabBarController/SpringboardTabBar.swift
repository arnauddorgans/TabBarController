//
//  SpringboardTabBar.swift
//  TabBarController
//
//  Created by Arnaud Dorgans on 19/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class SpringboardTabBarItem: UITabBarItem {
    
    @IBInspectable var tintColor: UIColor = .white
    @IBInspectable var backgroundColor: UIColor = .darkGray
    
    convenience init(image: UIImage?, tintColor: UIColor = .white, backgroundColor: UIColor) {
        self.init(title: nil, image: image, tag: 0)
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
    }
}

@IBDesignable class SpringboardTabBar: UIView, TabBarProtocol {
    
    private let contentView = UIStackView()
    
    weak var delegate: TabBarDelegate?

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
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 30
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        backgroundView.heightAnchor.constraint(equalToConstant: 94).isActive = true
        backgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 10).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        if #available(iOS 11.0, tvOS 11.0, *) {
            backgroundView.topAnchor.constraint(greaterThanOrEqualTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            backgroundView.topAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        }
        let top = backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10)
        top.priority = .defaultHigh
        top.isActive = true
        
        let bottom = backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        bottom.priority = .defaultHigh
        bottom.isActive = true
        
        contentView.axis = .horizontal
        contentView.distribution = .fillEqually
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        contentView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor).isActive = true
    }
    
    @objc func didSelectButton(_ sender: SpringboardTabBarButton) {
        self.delegate?.tabBar(self, didSelect: sender.item)
    }
    
    
    // MARK: TabBarProtocol
    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        items?.forEach {
            guard let item = SpringboardTabBarButton(item: $0) else {
                return
            }
            item.addTarget(self, action: #selector(self.didSelectButton(_:)), for: .touchUpInside)
            contentView.addArrangedSubview(item)
        }
    }
    
    func setSelectedItem(_ item: UITabBarItem?, animated: Bool) {
        
    }
    
    // MARK: HitTest
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let point = self.convert(point, to: contentView)
        return contentView.hitTest(point, with: event)
    }
    
    // MARK: Designable
    override func prepareForInterfaceBuilder() {
        let items = [SpringboardTabBarItem(image: UIImage(named: "baseline-account_circle-24px", in: Bundle(for: SpringboardTabBar.self), compatibleWith: nil), backgroundColor: .red),
                     SpringboardTabBarItem(image: UIImage(named: "baseline-chrome_reader_mode-24px", in: Bundle(for: SpringboardTabBar.self), compatibleWith: nil), backgroundColor: .blue)]
        self.setItems(items, animated: false)
        self.setSelectedItem(items.first, animated: false)
    }
}

class SpringboardTabBarButton: UIButton {
    
    fileprivate let itemImageView = UIImageView()
    
    let item: SpringboardTabBarItem
    
    init?(item: UITabBarItem) {
        guard let item = item as? SpringboardTabBarItem else {
            return nil
        }
        self.item = item
        super.init(frame: .zero)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = .zero
        
        itemImageView.tintColor = item.tintColor
        itemImageView.backgroundColor = item.backgroundColor
        itemImageView.contentMode = .center
        itemImageView.clipsToBounds = true
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(itemImageView)
        itemImageView.heightAnchor.constraint(equalTo: itemImageView.widthAnchor).isActive = true
        itemImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 2 / 3).isActive = true
        itemImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        itemImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.widthAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor).isActive = true
        
        update()
    }
    
    private func update() {
        itemImageView.image = item.image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemImageView.layer.cornerRadius = self.frame.height / 6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
