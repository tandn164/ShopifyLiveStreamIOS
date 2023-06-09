//
//  Application.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit

final class Application {
    static let shared = Application()

    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainTabBarController = storyboard.instantiateViewController(
            withIdentifier: "SwitcherViewController") as? SwitcherViewController {
            window.rootViewController = mainTabBarController
        }
    }
}
