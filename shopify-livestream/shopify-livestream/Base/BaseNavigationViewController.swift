//
//  BaseNavigationViewController.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit

final class BaseNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = UIColor.primaryColor
        navigationBar.backgroundColor = UIColor.white
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.primaryColor]
            appearance.backgroundColor = UIColor.white
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
