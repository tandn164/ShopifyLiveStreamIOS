//
//  GroupInviteView.swift
//  FammiActor
//
//  Created by Ngo  Hien on 30/11/2020.
//  Copyright © 2020 SotaTek. All rights reserved.
//

import UIKit

protocol GroupInviteViewDelegate: AnyObject {
    func closeList()
    func inviteUser(user: Viewer)
    func kickUser(user: Viewer)
}

class GroupInviteView: UIView, AppViewProtocol {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keywordTextfield: UITextField!
    
    weak var delegate: GroupInviteViewDelegate?
    var listUser: [Viewer] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: "GroupInviteView")
        initSubview()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: "GroupInviteView")
        initSubview()
    }
    
    func initSubview() {
        keywordTextfield.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCellByNib(GroupInviteTableViewCell.self)
    }
    
    func search(_ keyword: String) {
    }
    
    func showSearchToolbar() {
        keywordTextfield.becomeFirstResponder()
    }

    func hideSearchToolbar() {
        keywordTextfield.resignFirstResponder()
    }
    
    @IBAction func onHideKeyboardlicked(_ sender: AnyObject) {
        keywordTextfield.resignFirstResponder()
    }
    
    @IBAction func onCloseClicked(_ sender: AnyObject) {
        keywordTextfield.text = ""
        keywordTextfield.resignFirstResponder()
        self.search(keywordTextfield.text ?? "")
        delegate?.closeList()
    }
    
    @IBAction func onSearchClicked(_ sender: AnyObject) {
        keywordTextfield.resignFirstResponder()
        self.search(keywordTextfield.text ?? "")
    }
}

extension GroupInviteView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keywordTextfield.resignFirstResponder()
        self.search(keywordTextfield.text ?? "")
        return true
    }
}

extension GroupInviteView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(GroupInviteTableViewCell.self, forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        cell.setupUI(user: listUser[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension GroupInviteView: GroupInviteTableViewCellDelegate {
    func inviteUser(user: Viewer) {
        delegate?.inviteUser(user: user)
        delegate?.closeList()
    }
    
    func kickUser(user: Viewer) {
        delegate?.kickUser(user: user)
        delegate?.closeList()
    }
}
