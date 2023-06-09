//
//  LiveByCategoryTableViewCell.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 07/08/2022.
//

import UIKit

class LiveByCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var lives: [Room] = []
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        collectionView.registerCellByNib(LiveByCategoryCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func initData(title: String, lives: [Room]) {
        titleLabel.text = title
        self.lives = lives
        collectionView.reloadData()
    }
}

extension LiveByCategoryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if lives.isEmpty {
            let view = UIView()            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "There are no lives at the moment"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = UIColor.primaryColor
            view.addSubview(label)
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
            collectionView.backgroundView = view
        } else {
            collectionView.backgroundView = nil
        }
        return lives.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(LiveByCategoryCollectionViewCell.self,
                                                    forIndexPath: indexPath) else {
            return UICollectionViewCell()
        }
        cell.initData(live: lives[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (DeviceInfo.width - 60) / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
    }
}
