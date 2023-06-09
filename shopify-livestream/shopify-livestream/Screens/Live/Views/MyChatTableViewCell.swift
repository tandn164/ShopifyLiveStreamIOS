//
//  MyChatTableViewCell.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 10/07/2022.
//

import UIKit

class MyChatTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    var data: ChatMessage? {
        didSet {
            messageLabel.text = data?.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
