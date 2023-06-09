//
//  MainTabbarController.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit

enum TabType {
    case home
    case cart
    case notification
    case myPage
    
    var name: String {
        switch self {
        case .home:
            return "Discovery"
        case .cart:
            return "Cart"
        case .notification:
            return "Notification"
        case .myPage:
            return "My page"
        }
    }
    
    var iconOn: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "ic_home_on")
        case .cart:
            return UIImage(named: "ic_cart_on")
        case .notification:
            return UIImage(named: "ic_notification_on")
        case .myPage:
            return UIImage(named: "ic_mypage_on")
        }
        
    }
    
    var iconOff: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "ic_home_off")
        case .cart:
            return UIImage(named: "ic_cart_off")
        case .notification:
            return UIImage(named: "ic_notification_off")
        case .myPage:
            return UIImage(named: "ic_mypage_off")
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .home:
            let vc: BaseViewController
            vc = HomeViewController()
            vc.title = name
            return vc
        case .cart:
            let vc: BaseViewController
            vc = CartViewController()
            vc.title = name
            return vc
        case .notification:
            let vc: BaseViewController
            vc = NotificationViewController()
            vc.title = name
            return vc
        case .myPage:
            let vc: BaseViewController
            vc = MyPageViewController()
            vc.title = name
            return vc
        }
        
    }
}

protocol TabBarReselectHandling {
    func handleReselect()
}

final class MainTabBarController: UITabBarController {
    
    private let mainTabBars: [TabType] = [.home, .cart, .notification, .myPage]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupView()
    }
    
    private func setupView() {
        let appearance = UITabBarItem.appearance()
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.grayText],
                                          for: .normal)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.primaryColor],
                                          for: .selected)
        appearance.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        
        
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.grayText, .font: UIFont.systemFont(ofSize: 12)]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.primaryColor, .font: UIFont.boldSystemFont(ofSize: 12)]
            
            
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
        
        let viewControllers = mainTabBars.map { tab -> UIViewController in
            let tabBarItem = UITabBarItem(title: tab.name,
                                          image: tab.iconOff?.withRenderingMode(.alwaysTemplate),
                                          selectedImage: tab.iconOn?.withRenderingMode(.alwaysOriginal))
            
            let viewController = BaseNavigationViewController(rootViewController: tab.viewController)
            viewController.tabBarItem = tabBarItem
            return viewController
        }
        
        self.viewControllers = viewControllers
        self.selectedViewController = viewControllers[0]
        
    }
    
    override var selectedViewController: UIViewController? {
        didSet {
            
            guard let viewControllers = viewControllers else {
                return
            }
            
            for viewController in viewControllers {
                if viewController == selectedViewController {
                    viewController.tabBarItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 12)], for: .normal)
                } else {
                    viewController.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12)], for: .normal)
                }
            }
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        if tabBarController.selectedViewController == viewController {
            guard let navigationController = viewController as? UINavigationController else { return true }
            guard navigationController.viewControllers.count <= 1,
                  let handler = navigationController.viewControllers.first as? TabBarReselectHandling else { return true }
            handler.handleReselect()
        }
        return true
    }
}
