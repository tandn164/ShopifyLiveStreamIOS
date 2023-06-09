//
//  SignUpViewController.swift
//  FammiUser
//
//  Created by Ngo  Hien on 11/6/20.
//  Copyright © 2020 SotaTek. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignUpViewController: BaseViewController {

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var storeTextField: UITextField!
    
    var observer: NSKeyValueObservation?
    var notificationObserver: NSKeyValueObservation?
    let db = Firestore.firestore()
    var firstLoad = true

    deinit {
        observer?.invalidate()
        notificationObserver?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observer = UserDefaults.standard.observe(\.shopifyToken, options: [.initial, .new], changeHandler: { (defaults, change) in
            DispatchQueue.main.async {
                self.registerProcess()
            }
        })
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        guard let storeName = storeTextField.text, !storeName.isEmpty else {
            UIAlertController.show(message: "Please enter your store name", title: nil)
            return
        }
        if confirmPasswordTextField.text != passwordTextField.text {
            UIAlertController.show(message: "Re-confirm your password", title: nil)
            return
        }
        if let url = URL(string: "https://tannd176865.myshopify.com/admin/oauth/install_custom_app?client_id=ca55bfa331d5dad3456dd37aa9aed3ba&signature=eyJfcmFpbHMiOnsibWVzc2FnZSI6ImV5SmxlSEJwY21WelgyRjBJam94TmpZeE5EWTBPVGs1TENKd1pYSnRZVzVsYm5SZlpHOXRZV2x1SWpvaWRHRnVibVF4TnpZNE5qVXViWGx6YUc5d2FXWjVMbU52YlNJc0ltTnNhV1Z1ZEY5cFpDSTZJbU5oTlRWaVptRXpNekZrTldSaFpETTBOVFprWkRNM1lXRTVZV1ZrTTJKaElpd2ljSFZ5Y0c5elpTSTZJbU4xYzNSdmJWOWhjSEFpZlE9PSIsImV4cCI6IjIwMjItMDktMDFUMjI6MDM6MTkuMjEyWiIsInB1ciI6bnVsbH19--07d316ecb85e6ceef2029f85089a87b31928d6e6") {
            UIApplication.shared.open(url)
        }
    }
    
    func registerProcess() {
        print(DataLocal.shopifyToken)
        if firstLoad {
            firstLoad = false
            return
        }
        Auth.auth().createUser(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { authResult, error in
            guard error == nil else {
                UIAlertController.show(message: error?.localizedDescription, title: nil)
                return
            }
            let uid = Auth.auth().currentUser?.uid ?? ""
            let user = User(email: self.emailTextField.text,
                            password: self.passwordTextField.text,
                            storeName: self.storeTextField.text,
                            shopifyToken: DataLocal.shopifyToken,
                            role: "store_owner",
                            thumb: nil,
                            balace: nil,
                            coinBalance: nil,
                            agoraUID: UInt.random(in: 0..<10000000))
            
            self.db.collection("users").document(uid).setData(user.dictionary) { err in
                if let err = err {
                    UIAlertController.show(message: err.localizedDescription, title: nil)
                } else {
                    DataLocal.saveData(forKey: AppKey.userInfo, user)
                    let vc = MainTabbarController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}


