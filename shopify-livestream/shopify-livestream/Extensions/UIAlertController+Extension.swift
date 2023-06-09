//
//  UIAlert+Extension.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 28/04/2022.
//

import UIKit

extension UIAlertController {
    static func show(message: String? = nil, title: String? = nil) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        
        let titleAttrString = NSAttributedString(
            string: title ?? "",
            attributes: [NSAttributedString.Key.font: UIFont.hiraginoW6(17)])
        
        let messageAttrString = NSAttributedString(
            string: message ?? "",
            attributes: [NSAttributedString.Key.font: UIFont.hiraginoW3(12),
                         NSAttributedString.Key.paragraphStyle: paragraph
                        ])
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.setValue(titleAttrString, forKey: "attributedTitle")
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        UIApplication.shared.topMostViewController()?.present(alertController, animated: true)
    }
}
