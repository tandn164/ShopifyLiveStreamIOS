//
//  AuthViewController.swift
//  FammiUser
//
//  Created by Ngo  Hien on 11/6/20.
//  Copyright © 2020 SotaTek. All rights reserved.
//

import UIKit

class AuthViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func signInAction(_ sender: UIButton) {
        let vc = SignInViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
