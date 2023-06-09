//
//  LiveProductCollectionViewCell.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 17/07/2022.
//

import UIKit
import Kingfisher

protocol LiveProductCollectionViewCellDelegate: AnyObject {
    func removeProduct(at indexPath: IndexPath)
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
    }

    @IBAction func deleteProduct(_ sender: UIButton) {
        guard let indexPath = indexPath else {
            return
        }
        delegate?.removeProduct(at: indexPath)
    }
}
