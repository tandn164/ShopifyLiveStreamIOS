//
//  UIFont+Extension.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 27/04/2022.
//

import UIKit

extension UIFont {
    static func hiraginoW3(_ size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W3", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func hiraginoW6(_ size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W6", size: size) ?? .boldSystemFont(ofSize: size)
    }
}
