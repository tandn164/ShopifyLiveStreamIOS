//
//  GroupInviteTableViewCell.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 06/08/2022.
//

import UIKit
import Kingfisher

protocol GroupInviteTableViewCellDelegate: AnyObject {
    func inviteUser(user: Viewer)
    func kickUser(user: Viewer)
}

class GroupInviteTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var thumbnail: UIImageView!
    
    weak var delegate: GroupInviteTableViewCellDelegate?
    var user: Viewer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupUI(user: Viewer) {
        self.user = user
        self.name.text = user.username
        self.thumbnail.kf.setImage(with: URL(string: user.thumbnail ?? ""),
                                   placeholder: UIImage(named: "audience"))
        print(3444, user.isInvited)
        if user.isInvited ?? false {
            inviteButton.setTitle("Kick", for: .normal)
            inviteButton.backgroundColor = UIColor(hex: "#C70000")
        } else {
            inviteButton.setTitle("Invite", for: .normal)
            inviteButton.backgroundColor = UIColor(hex: "#1D479B")
        }
    }
    
    @IBAction func inviteAction(_ sender: UIButton) {
        guard let user = user else {
            return
        }

        if user.isInvited ?? false {
            delegate?.kickUser(user: user)
        } else {
            delegate?.inviteUser(user: user)
        }
    }
}
