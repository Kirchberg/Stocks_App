//
//  UICollectionView+CollectionSkeleton.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 02/02/2018.
//  Copyright © 2018 SkeletonView. All rights reserved.
//

import UIKit

extension UICollectionView: CollectionSkeleton {
    var estimatedNumberOfRows: Int {
        guard let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        return Int(ceil(frame.height / flowlayout.itemSize.height))
    }

    var skeletonDataSource: SkeletonCollectionDataSource? {
        get { return ao_get(pkey: &CollectionAssociatedKeys.dummyDataSource) as? SkeletonCollectionDataSource }
        set {
            ao_setOptional(newValue, pkey: &CollectionAssociatedKeys.dummyDataSource)
            dataSource = newValue
        }
    }

    var skeletonDelegate: SkeletonCollectionDelegate? {
        get { return ao_get(pkey: &CollectionAssociatedKeys.dummyDelegate) as? SkeletonCollectionDelegate }
        set {
            ao_setOptional(newValue, pkey: &CollectionAssociatedKeys.dummyDelegate)
            delegate = newValue
        }
    }

    func addDummyDataSource() {
        guard let originalDataSource = self.dataSource as? SkeletonCollectionViewDataSource,
              !(originalDataSource is SkeletonCollectionDataSource)
        else { return }

        let dataSource = SkeletonCollectionDataSource(collectionViewDataSource: originalDataSource)
        skeletonDataSource = dataSource
        reloadData()
    }

    func updateDummyDataSource() {
        if (dataSource as? SkeletonCollectionDataSource) != nil {
            reloadData()
        } else {
            addDummyDataSource()
        }
    }

    func removeDummyDataSource(reloadAfter: Bool) {
        guard let dataSource = self.dataSource as? SkeletonCollectionDataSource else { return }
        skeletonDataSource = nil
        self.dataSource = dataSource.originalCollectionViewDataSource
        if reloadAfter { reloadData() }
    }
}

extension UICollectionView: GenericCollectionView {
    var scrollView: UIScrollView { return self }
}

public extension UICollectionView {
    func prepareSkeleton(completion: @escaping (Bool) -> Void) {
        guard let originalDataSource = self.dataSource as? SkeletonCollectionViewDataSource,
              !(originalDataSource is SkeletonCollectionDataSource)
        else { return }

        let dataSource = SkeletonCollectionDataSource(collectionViewDataSource: originalDataSource, rowHeight: 0.0)
        skeletonDataSource = dataSource
        performBatchUpdates({
            self.reloadData()
        }) { done in
            completion(done)
        }
    }
}
