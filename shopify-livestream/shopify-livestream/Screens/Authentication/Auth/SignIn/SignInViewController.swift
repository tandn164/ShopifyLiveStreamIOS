//
//  SignInViewController.swift
//  FammiUser
//
//  Created by Ngo  Hien on 11/6/20.
//  Copyright © 2020 SotaTek. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class SignInViewController: BaseViewController {
    
    @IBOutlet weak var mailTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: mailTextfield.text ?? "",
                           password: passwordTextField.text ?? "") { authResult, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            }
            let uid = Auth.auth().currentUser?.uid ?? ""

            let docRef = self.db.collection(FirebaseKey.users).document(uid)
            print(uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists, let dictionary = document.data() {
                    let user = User(dictionary: dictionary)
                    DataLocal.saveData(forKey: AppKey.userInfo, user)
                    
                    print(DataLocal.getData(forKey: AppKey.userInfo) as? User)
                    
                    let vc = MainTabBarController()
                    if #available(iOS 13.0, *) {
                        UIApplication.shared.windows.first?.rootViewController = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    } else {
                        UIApplication.shared.keyWindow?.set(rootViewController: vc)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}
