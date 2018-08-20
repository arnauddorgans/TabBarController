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
    
    private let itemImageView = UIImageView()
    private let badgeView = SpringboardTabBarButtonBadgeView()
    
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
        
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(badgeView)
        badgeView.centerXAnchor.constraint(equalTo: itemImageView.rightAnchor, constant: -3).isActive = true
        badgeView.centerYAnchor.constraint(equalTo: itemImageView.topAnchor, constant: 3).isActive = true
        
        self.widthAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor).isActive = true
        
        addObserver()
        update()
    }
    
    private func update() {
        itemImageView.image = item.image
        updateBadge()
    }
    
    private func updateBadge() {
        badgeView.setText(item.badgeValue, animated: true)
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemImageView.layer.cornerRadius = self.frame.height / 6
    }
    
    // MARK: KVO
    private func addObserver() {
        item.addObserver(self, forKeyPath: #keyPath(UITabBarItem.badgeValue), options: .new, context: nil)
    }
    
    private func removeObserver() {
        item.removeObserver(self, forKeyPath: #keyPath(UITabBarItem.badgeValue))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateBadge()
    }
    
    deinit {
        self.removeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SpringboardTabBarButtonBadgeView: UIView {
    
    private let label = UILabel()
    private let backgroundView = UIView()
    
    var text: String? {
        get { return label.text }
        set { self.setText(newValue, animated: false) }
    }

    init() {
        super.init(frame: .zero)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.2
        self.isUserInteractionEnabled = false
        
        backgroundView.backgroundColor = .red
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        backgroundView.addSubview(label)
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor).isActive = true
        self.setText(nil, animated: false)
    }
    
    func setText(_ string: String?, animated: Bool) {
        label.text = string
        func updateOpacity() {
            self.alpha = string?.isEmpty == false ? 1 : 0
        }
        guard animated else {
            updateOpacity()
            return
        }
        UIView.animate(withDuration: 0.1, animations: {
            updateOpacity()
            self.backgroundView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.backgroundView.transform = .identity
            }, completion: nil)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.layer.cornerRadius = self.frame.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
