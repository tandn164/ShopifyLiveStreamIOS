//
//  LiveByCategoryCollectionViewCell.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 26/04/2022.
//

import UIKit
import SDWebImage

class LiveByCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var actorLabel: UILabel!
    @IBOutlet weak var liveView: UIButton!
    @IBOutlet weak var numberViewerView: UIButton!
    @IBOutlet weak var liveNewImageView: UIImageView!
    @IBOutlet weak var liveHotImageView: UIImageView!
    
    private var liveInfo: Room?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    func initData(live: Room) {
        self.liveInfo = live
        thumbImageView.sd_setImage(with: URL(string: live.thumb ?? "https://assets.adidas.com/images/h_840,f_auto,q_auto,fl_lossy,c_fill,g_auto/b743345901d446e6b956ae6f0125d81f_9366/Giay_Forum_Low_trang_GW7107_01_standard.jpg"),
                                   placeholderImage: UIImage(named: "test_image"))
        titleLabel.text = live.name
        actorLabel.text = live.actorName
        liveView.isHidden = true
        liveNewImageView.isHidden = true
        liveHotImageView.isHidden = true
        numberViewerView.isHidden = false
        numberViewerView.setTitle("\(live.viewer?.count ?? 0)", for: .normal)
    }
    
    @objc private func tapped() {
        let vc = LiveViewController()
        vc.roomInfo = liveInfo
        vc.modalPresentationStyle = .fullScreen
        UIApplication.shared.topMostViewController()?.present(vc, animated: true)
    }
}
