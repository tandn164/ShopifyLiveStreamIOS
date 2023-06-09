//
//  AppDelegate.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 15/04/2022.
//

import UIKit
import FirebaseCore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)

        Application.shared.configureMainInterface(in: window)
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        SocketHandler.sharedInstance.establishConnection()

        self.window = window
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }

        guard let params = components.queryItems else {
            return false
        }
        
        if let token = params.first(where: { $0.name == "token" } )?.value {
            DataLocal.shopifyToken = token
            return true
        } else {
            print("No token")
            return false
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketHandler.sharedInstance.closeConnection()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
