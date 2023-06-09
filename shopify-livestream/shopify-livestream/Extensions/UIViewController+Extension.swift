//
//  UIViewController+Extension.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 28/04/2022.
//

import UIKit

public extension UIViewController {
    /**
     * 最前面に表示している`ViewController`のインスタンスを取得する
     */
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigationController = self.navigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? navigationController
        }
        if let tabBarController = self.tabBarController {
            if let selected = tabBarController.selectedViewController {
                return selected.topMostViewController()
            }
            return tabBarController.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
    func showAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var allButtons = buttonTitles ?? [String]()
        if allButtons.count == 0 {
            allButtons.append("OK")
        }
        
        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
                completion?(index)
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                if #available(iOS 9.0, *) {
                    alertController.preferredAction = action
                }
            }
        }
        present(alertController, animated: true, completion: nil)
        return alertController
    }
    
}

extension UIViewController {
    @objc var backButtonTitle: String? {
        get {
            return navigationItem.backBarButtonItem?.title
        }
        set {
            if let existingBackBarButtonItem = navigationItem.backBarButtonItem {
                existingBackBarButtonItem.title = newValue
            }
            else {
                let newNavigationItem = UIBarButtonItem(title: newValue, style:.plain, target: nil, action: nil)
                navigationItem.backBarButtonItem = newNavigationItem
            }
        }
    }
    
    @objc var screenTitle: String {
        get {
            return (navigationItem.titleView as? UILabel)?.text ?? ""
        }
        set {
            if let label = navigationItem.titleView as? UILabel {
                label.text = newValue
            } else {
                let label = UILabel()
                label.font = UIFont.hiraginoW6(18)
                label.textColor = UIColor.appLightBlack
                label.text = newValue
                navigationItem.titleView = label
            }
        }
    }
}
