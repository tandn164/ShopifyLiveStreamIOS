//
//  SwitcherViewController.swift
//  Exclusiv
//
//  Created by Thanh Tran on 1/14/17.
//  Copyright © 2017 SotaTek. All rights reserved.
//

import UIKit
import FirebaseAuth

enum SwitcherAction {
    case openMedia
}

class SwitcherViewController: BaseViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isLoggedIn = Auth.auth().currentUser?.uid != nil
        if isLoggedIn {
            showMainViewController()
        } else {
            let vc =  AuthViewController()
            let nacVC = BaseNavigationViewController(rootViewController: vc)
            nacVC.modalPresentationStyle = .fullScreen
            self.present(nacVC, animated: true, completion: nil)
        }
    }

    func showMainViewController() {
        let vc = MainTabBarController()
        if #available(iOS 13.0, *) {
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } else {
            UIApplication.shared.keyWindow?.set(rootViewController: vc)
        }
    }
}

extension UIWindow {
    
    /// Fix for http://stackoverflow.com/a/27153956/849645
    func set(rootViewController newRootViewController: UIViewController, withTransition transition: CATransition? = nil) {
        
        let previousViewController = rootViewController
        
        if let transition = transition {
            // Add the transition
            layer.add(transition, forKey: kCATransition)
        }
        
        rootViewController = newRootViewController
        
        // Update status bar appearance using the new view controllers appearance - animate if needed
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }
        
        /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}
