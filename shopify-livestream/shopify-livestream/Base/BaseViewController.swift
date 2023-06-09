//
//  BaseViewController.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit

class BaseViewController: UIViewController {
    
    let backButton = UIButton(type: .custom)
    var isClearNavigationBar = false
    var isHiddenNavBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackBarButton()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditting)))
    }
    
    deinit {
        navigationController?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if isClearNavigationBar {
            clearNavigationBar()
        } else {
            navigationController?.navigationBar.isTranslucent = false
        }
        navigationController?.setNavigationBarHidden(isHiddenNavBar, animated: true)
    }
    
    func addBackBarButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
    }
    
    @objc func onClose() {
        dismiss(animated: true)
    }
    
    func clearNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    // MARK: - Create fake navigation bar
    
//    let navItem = UINavigationItem(title: "")
//
//    var statusView = UIView(frame: CGRect(x: 0,
//                                          y: 0,
//                                          width: DeviceInfo.width,
//                                          height: view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0))
//
//    var fakeNavBar = UINavigationBar(frame: CGRect(x: 0,
//                                                   view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0,
//                                                   width: DeviceInfo.width,
//                                                   height: 44))
//
//    func addFakeNavigationBar() {
//
//        statusView.backgroundColor = UIColor.grayBackground
//        fakeNavBar.setItems([navItem], animated: false)
//        fakeNavBar.shadowImage = UIColor.grayBackground?.image()
//        fakeNavBar.setBackgroundImage(UIImage(),
//                                      for: .default)
//        fakeNavBar.backgroundColor = UIColor.grayBackground
//        view.addSubview(fakeNavBar)
//        view.addSubview(statusView)
//    }
    
    @objc func endEditting() {
        view.endEditing(true)
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
