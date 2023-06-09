//
//  MyPageViewController.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class MyPageViewController: BaseViewController {
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var zipcode: UITextField!
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        email.text = currentUser.email
        db.collection("users").document(currentUser.uid).getDocument { document, error in
            let user = User(dictionary: document?.data() ?? [:])
            let address = user.address
            self.firstname.text = address?.firstName
            self.lastname.text = address?.lastName
            self.address.text = address?.address1
            self.phonenumber.text = address?.phone
            self.city.text = address?.city
            self.country.text = address?.country
            self.zipcode.text = address?.zip
        }
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        if (firstname.text?.isEmpty ?? true)
            || (lastname.text?.isEmpty ?? true)
            || (address.text?.isEmpty ?? true)
            || (phonenumber.text?.isEmpty ?? true)
            || (city.text?.isEmpty ?? true)
            || (country.text?.isEmpty ?? true)
            || (zipcode.text?.isEmpty ?? true) {
            UIAlertController.show(message: "You must fill all address infomation before submit", title: nil)
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let address = AddressModel(firstName: self.firstname.text,
                                   lastName: self.lastname.text,
                                   address1: self.address.text,
                                   phone: self.phonenumber.text,
                                   city: self.city.text,
                                   country: self.country.text,
                                   zip: self.zipcode.text)
        db.collection("users").document(currentUser.uid).updateData(["address" : address.dictionary]) { error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
            } else {
                UIAlertController.show(message: "Success!!!", title: nil)
            }
        }
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            DataLocal.saveData(forKey: AppKey.userInfo, nil)
            let vc = SwitcherViewController()
            if #available(iOS 13.0, *) {
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            } else {
                UIApplication.shared.keyWindow?.set(rootViewController: vc)
            }
        } catch {
        }
    }
}
