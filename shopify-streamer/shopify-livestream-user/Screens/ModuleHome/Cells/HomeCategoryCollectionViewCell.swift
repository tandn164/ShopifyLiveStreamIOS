//
//  HomeCategoryCollectionViewCell.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 17/07/2022.
//

import UIKit

class HomeCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberOfItemLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindData(_ data: Category, _ isSelected: Bool) {
        titleLabel.text = data.title
        self.numberOfItemLabel.text = "\(data.products?.count ?? 0)"
        if isSelected {
            titleLabel.textColor = UIColor.white
            backgroundColor = UIColor(hex: "253E8F")
        } else {
            titleLabel.textColor = UIColor.black
            backgroundColor = UIColor(hex: "E4E4E4")
        }
    }
}
