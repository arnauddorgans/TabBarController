//
//  YoutubeTabBar.swift
//  TabBarController_Example tvOS
//
//  Created by Arnaud Dorgans on 11/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

@objc enum YoutubeAction: Int {
    case search
    
    var image: UIImage? {
        switch self {
        case .search:
            return UIImage(named: "baseline-search-24px", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil)
        }
    }
}

class YoutubeTabBarItem: UITabBarItem {
    
    @IBInspectable var isAccessory: Bool = false
    var action: YoutubeAction?
    
    var isAction: Bool {
        return action != nil
    }
    
    convenience init(image: UIImage?, isAccessory: Bool) {
        self.init()
        self.isAccessory = isAccessory
        self.image = image
    }
    
    convenience init(action: YoutubeAction, isAccessory: Bool) {
        self.init()
        self.action = action
        self.isAccessory = isAccessory
        self.image = action.image
    }
}

@objc protocol YoutubeTabBarDelegate: class {
    
    @objc func youtubeTabBar(_ youtubeTabBar: YoutubeTabBar, didTriggerAction action: YoutubeAction)
}

@IBDesignable class YoutubeTabBar: UIView, TabBarProtocol {
    
    private let logoImageView = UIImageView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let accessoryStackView = UIStackView()

    private let youtubeAnimator = YoutubeTabBarAnimator()
    
    weak var delegate: TabBarDelegate?
    @IBOutlet weak var youtubeDelegate: YoutubeTabBarDelegate?
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [stackView.arrangedSubviews, accessoryStackView.arrangedSubviews]
            .flatMap { $0 }
            .sorted(by: { lhs, _ in (lhs as? YoutubeTabBarButton)?.isSelected == true })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    private func sharedInit() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 8, height: 0)
        self.layer.shadowOpacity = 0.3
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor(named: "Theme", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil)
        self.addSubview(contentView)
        contentView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        logoImageView.image = UIImage(named: "yt_icon_rgb", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .center
        self.addSubview(logoImageView)
        logoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        logoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        logoImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor).isActive = true
        
        accessoryStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(accessoryStackView)
        accessoryStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        accessoryStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        accessoryStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        [stackView, accessoryStackView].forEach {
            $0.axis = .vertical
            $0.distribution = .fillEqually
        }
    }
    
    func setSelectedItem(_ item: UITabBarItem?, animated: Bool) {
        [stackView.arrangedSubviews, accessoryStackView.arrangedSubviews]
            .flatMap { $0 }
            .forEach {
                guard let button = $0 as? YoutubeTabBarButton else {
                    return
                }
                button.isSelected = button.item == item
        }
    }
    
    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        [stackView.arrangedSubviews, accessoryStackView.arrangedSubviews]
            .flatMap { $0 }
            .forEach { $0.removeFromSuperview() }
        let items = [[YoutubeTabBarItem(action: .search, isAccessory: false)], items ?? []].flatMap { $0 }
        items.forEach {
            guard let button = YoutubeTabBarButton(item: $0) else {
                return
            }
            button.addTarget(self, action: #selector(self.didTapButton(_:)), for: .primaryActionTriggered)
            if button.item.isAccessory {
                accessoryStackView.addArrangedSubview(button)
            } else {
                stackView.addArrangedSubview(button)
            }
        }
    }
    
    @objc func didTapButton(_ sender: Any) {
        guard let button = sender as? YoutubeTabBarButton,
            let action = button.item.action else {
            return
        }
        self.youtubeDelegate?.youtubeTabBar(self, didTriggerAction: action)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let button = context.nextFocusedView as? YoutubeTabBarButton else {
            return
        }
        self.delegate?.tabBar(self, didSelect: button.item)
    }
    
    func animator() -> TabBarAnimator? {
        return youtubeAnimator
    }
    
    override func prepareForInterfaceBuilder() {
        let items = [YoutubeTabBarItem(image: UIImage(named: "baseline-home-24px", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil), isAccessory: false),
                     YoutubeTabBarItem(image: UIImage(named: "baseline-video_library-24px", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil), isAccessory: false),
                     YoutubeTabBarItem(image: UIImage(named: "baseline-folder-24px", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil), isAccessory: false),
                     YoutubeTabBarItem(image: UIImage(named: "baseline-account_circle-24px", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil), isAccessory: true),
                     YoutubeTabBarItem(image: UIImage(named: "baseline-settings-20px", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil), isAccessory: true)]
        self.setItems(items, animated: false)
        self.setSelectedItem(items.first, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private class YoutubeTabBarButton: UIButton {
    
    private let logoView = UIImageView()
    private let backgroundView = UIView()
    private let roundedBackgroundView = UIView()
    
    let item: YoutubeTabBarItem
    
    init?(item: UITabBarItem) {
        guard let item = item as? YoutubeTabBarItem else {
            return nil
        }
        self.item = item
        super.init(frame: .zero)
        
        roundedBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 5)
        roundedBackgroundView.layer.shadowColor = UIColor.black.cgColor
        roundedBackgroundView.layer.shadowOpacity = 1
        roundedBackgroundView.isUserInteractionEnabled = false
        roundedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(roundedBackgroundView)
        roundedBackgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        roundedBackgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        roundedBackgroundView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9).isActive = true
        roundedBackgroundView.widthAnchor.constraint(equalTo: roundedBackgroundView.heightAnchor).isActive = true
        
        backgroundView.isUserInteractionEnabled = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        logoView.image = item.image
        logoView.contentMode = .center
        logoView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(logoView)
        logoView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        logoView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        logoView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        logoView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor, multiplier: 0.6).isActive = true
        
        update()
    }
    
    private func update() {
        logoView.tintColor = {
            guard !self.isFocused else {
                return UIColor(named: "Theme", in: Bundle(for: YoutubeTabBar.self), compatibleWith: nil)
            }
            return self.isSelected ? UIColor.white : UIColor.white.withAlphaComponent(0.4)
        }()
        backgroundView.backgroundColor = self.isFocused ? .white : .clear
        roundedBackgroundView.backgroundColor = backgroundView.backgroundColor
        backgroundView.isHidden = self.item.isAction
        roundedBackgroundView.isHidden = !backgroundView.isHidden
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            self.update()
        }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundedBackgroundView.layer.cornerRadius = roundedBackgroundView.frame.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
