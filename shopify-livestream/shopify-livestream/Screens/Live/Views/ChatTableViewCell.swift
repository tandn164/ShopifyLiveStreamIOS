//
//  ChatTableViewCell.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 10/07/2022.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var data: ChatMessage? {
        didSet {
            messageLabel.text = data?.text
            userNameLabel.text = data?.username
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
