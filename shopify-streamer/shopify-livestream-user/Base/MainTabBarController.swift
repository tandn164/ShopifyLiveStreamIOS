//
//  MainTabbarController.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit
import SnapKit

struct Screen {
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    static var safeAreaHeight: CGFloat {
        return Screen.height - Screen.safeAreaBottom - Screen.safeAreaTop
    }
    
    static var safeAreaTop: CGFloat {
         if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindow {
                return window.safeAreaInsets.top
            }
         }
         return 0
    }
    
    static var safeAreaBottom: CGFloat {
        if #available(iOS 11, *) {
           if let window = UIApplication.shared.keyWindow {
               return window.safeAreaInsets.bottom
           }
        }
        return 0
    }
}

class Device {
    let isPad: Bool
    let statusBarHeight: CGFloat
    static let current = Device()

    init() {
        isPad = UIDevice.current.userInterfaceIdiom == .pad
        statusBarHeight = 20
    }

    /// 当前屏幕宽度与参考屏幕宽度（iPhone 375）的比例
    lazy var vwScale: CGFloat = { [unowned self] in
        let width: CGFloat = self.isPad ? 768 : 375
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / width
    }()

    /// 当前屏幕高度与参考屏幕高度（iPhone 667）的比例
    lazy var vhScale: CGFloat = {
        let height: CGFloat = self.isPad ? 1024 : 667
        return max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) / height
    }()
    
    lazy var vwScaleIphoneX: CGFloat = { [unowned self] in
        let widthIphoneX: CGFloat = 375
        return Screen.width / widthIphoneX
    }()
    
    lazy var vhScaleIphoneX: CGFloat = { [unowned self] in
        let heighIphoneX: CGFloat = 812
        return Screen.height / heighIphoneX
    }()

    /// 屏幕安全区域（适用于iPhoneX等的异形屏）
    var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets
                ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    var topNotchHeight: CGFloat {
        return self.safeAreaInsets.bottom > 0 ? 30 : 0
    }
    var leftMargin: CGFloat {
        return self.safeAreaInsets.left
    }
    var rightMargin: CGFloat {
        return self.safeAreaInsets.right
    }
    
    /// Device model
    lazy var modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
    
    class var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 24.0 on iPad Pro 12.9" 3rd generation, 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }
    
    class var hasBottomSafeAreaInsets: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with home indicator: 34.0 on iPhone X, XS, XS Max, XR.
            // with home indicator: 20.0 on iPad Pro 12.9" 3rd generation.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
    }
    
}
// MARK: - Vibration feedback
extension Device {
    func impactOccurred(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

public extension UIDevice {

    var modelName: String {

        #if targetEnvironment(simulator)
            let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        #endif

        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        default:                                        return identifier
        }
    }

}

class MainTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    let homeController = HomeViewController()
    let trendingController = TrendingViewController()
    var liveButton : LiveStreamButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let navHome = BaseNavigationViewController(rootViewController: homeController)
        let navTrending = BaseNavigationViewController(rootViewController: trendingController)
        navHome.tabBarItem = UITabBarItem(title: "My Shop",
                                          image: UIImage(named: "home_off_icon"),
                                          selectedImage: UIImage(named: "home_on_icon"))
        navTrending.tabBarItem = UITabBarItem(title: "List Orders",
                                              image: UIImage(named: "trending_off_icon"),
                                              selectedImage: UIImage(named: "trending_on_icon"))
        self.viewControllers = [navHome, BaseNavigationViewController(), navTrending]
        self.setupTabbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: Setup Tabbar
    func setupTabbar() {
        self.tabBar.barTintColor = UIColor(hex: "22213C")
        self.tabBar.tintColor = UIColor(hex: "253E8F")
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.white
        
        self.tabBar.backgroundColor = .white
        self.tabBar.invalidateIntrinsicContentSize()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: "A0A0A0")], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: "253E8F")], for: .selected)
        self.tabBar.standardAppearance = tabBarAppearance;
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = tabBarAppearance;
        }
        liveButton = LiveStreamButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0 ))
        tabBar.addSubview(liveButton)
        liveButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(0)
            make.width.equalTo(80)
            if #available(iOS 11.0, *) {
                make.height.equalTo(Device().safeAreaInsets.bottom+tabBar.frame.height+40)
            } else {
                make.height.equalTo(tabBar.frame.height+40)
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.navigateToLive))
        liveButton.isUserInteractionEnabled = true
        liveButton.addGestureRecognizer(tap)
    }
    
    //MARK: Navigate UI
    @objc func navigateToLive() {
        let vc = LiveViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
