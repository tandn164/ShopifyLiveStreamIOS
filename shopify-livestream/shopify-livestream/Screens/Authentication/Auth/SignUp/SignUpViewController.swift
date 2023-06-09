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
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        if confirmPasswordTextField.text != passwordTextField.text {
            UIAlertController.show(message: "Re-confirm your password", title: nil)
            return
        }
        Auth.auth().createUser(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { authResult, error in
            guard error == nil else {
                print(error)
                return
            }
            let uid = Auth.auth().currentUser?.uid ?? ""
            let user = User(email: self.emailTextField.text,
                            password: self.passwordTextField.text,
                            storeName: nil,
                            shopifyToken: nil,
                            role: "viewer",
                            thumb: nil,
                            balace: nil,
                            coinBalance: nil,
                            agoraUID: UInt.random(in: 0..<10000000)
            )
            
            self.db.collection("users").document(uid).setData(user.dictionary) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    DataLocal.saveData(forKey: AppKey.userInfo, user)
                    let vc = MainTabBarController()
                    if #available(iOS 13.0, *) {
                        UIApplication.shared.windows.first?.rootViewController = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    } else {
                        UIApplication.shared.keyWindow?.set(rootViewController: vc)
                    }
                }
            }
        }
    }
}


