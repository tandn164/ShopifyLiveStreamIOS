//
//  UIApplication+Extension.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 08/05/2022.
//

import UIKit

extension UIApplication {
    /**
     * アプリの最前面に表示している`ViewCotnroller`のインスタンスを取得する
     */
    func topMostViewController() -> UIViewController? {
        self.windows.first(where: {
            // アプリ内メッセージなど、明示的に他のWindowが開いているため
            // 画面遷移を正常に行えるように、インスタンスを明示的にする
            $0.isMember(of: UIWindow.self)
        })?.rootViewController?.topMostViewController()
    }
}
