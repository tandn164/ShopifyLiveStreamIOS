//
//  HomeVideosByCategoryTableViewCell.swift
//  YoutubeClone
//
//  Created by Đức Tân Nguyễn on 08/06/2021.
//

import UIKit

class HomeVideosByCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    func setupCollectionView() {
        collectionView.register(HomeVideoCollectionViewCell.nib(),
                                forCellWithReuseIdentifier: HomeVideoCollectionViewCell.nibName())
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension HomeVideosByCategoryTableViewCell: UICollectionViewDelegate,
                                             UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeVideoCollectionViewCell.nibName(),
                                                            for: indexPath) as? HomeVideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
