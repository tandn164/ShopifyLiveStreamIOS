//
//  AppDelegate.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 15/04/2022.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)

        Application.shared.configureMainInterface(in: window)
        IQKeyboardManager.shared.enable = true
        SocketHandler.sharedInstance.establishConnection()
        FirebaseApp.configure()
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.window = window
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketHandler.sharedInstance.closeConnection()
    }
}

