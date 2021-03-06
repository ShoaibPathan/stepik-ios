//
//  TrainingHorizontalCollectionCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class TrainingHorizontalCollectionCell: UICollectionViewCell, Reusable {
    let collectionView: TrainingHorizontalCollectionView

    var source: TrainingHorizontalCollectionSource? = nil {
        didSet {
            source?.register(for: collectionView)
        }
    }

    override init(frame: CGRect) {
        self.collectionView = TrainingHorizontalCollectionView()
        super.init(frame: frame)

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        source = nil
    }
}
