//
//  DeviceInfo.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit

struct DeviceInfo {
    static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    static var width: CGFloat {
        return screenSize.width
    }
    
    static var height: CGFloat {
        return screenSize.height
    }
    
    static var isPortrait: Bool {
        UIDevice.current.orientation == .portrait
            || UIDevice.current.orientation == .portraitUpsideDown
    }
}
