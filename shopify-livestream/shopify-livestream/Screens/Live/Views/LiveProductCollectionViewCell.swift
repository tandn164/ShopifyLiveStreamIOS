//
//  LiveProductCollectionViewCell.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 17/07/2022.
//

import UIKit
import Kingfisher

protocol LiveProductCollectionViewCellDelegate: AnyObject {
    func didSelect(at indexPath: IndexPath)
}

class LiveProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    weak var delegate: LiveProductCollectionViewCellDelegate?
    
    var indexPath: IndexPath?
    var liveProduct: LiveProduct? {
        didSet {
            priceLabel.text = "\(Util.formatNumber(liveProduct?.productPrice ?? 0))đ"
            let url = URL(string: liveProduct?.productThumbnail ?? "")
            imageView.kf.setImage(with: url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelect)))
    }
    
    @objc private func onSelect() {
        guard let indexPath = indexPath else {
            return
        }

        delegate?.didSelect(at: indexPath)
    }
}
