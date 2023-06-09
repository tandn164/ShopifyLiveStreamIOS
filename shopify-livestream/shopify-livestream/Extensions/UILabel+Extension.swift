//
//  UILabel+Extension.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 03/05/2022.
//

import UIKit

extension UILabel {
    func subTextColorChange(subText: String,
                            color: UIColor = UIColor.appBlack) {
        
        let range = ((self.text ?? "") as NSString).range(of: subText)
        let attribute = NSMutableAttributedString.init(string: self.text ?? "")
        attribute.addAttribute(NSAttributedString.Key.foregroundColor,
                               value: color,
                               range: range)
        self.attributedText = attribute
    }
}
