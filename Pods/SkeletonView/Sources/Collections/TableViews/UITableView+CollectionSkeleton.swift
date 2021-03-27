//
//  UITableView+CollectionSkeleton.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 02/02/2018.
//  Copyright © 2018 SkeletonView. All rights reserved.
//

import UIKit

public typealias ReusableHeaderFooterIdentifier = String

extension UITableView: CollectionSkeleton {
    var estimatedNumberOfRows: Int {
        return Int(ceil(frame.height / rowHeight))
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
        guard let originalDataSource = self.dataSource as? SkeletonTableViewDataSource,
              !(originalDataSource is SkeletonCollectionDataSource)
        else { return }
        let calculatedRowHeight = calculateRowHeight()
        let dataSource = SkeletonCollectionDataSource(tableViewDataSource: originalDataSource,
                                                      rowHeight: rowHeight,
                                                      originalRowHeight: rowHeight)
        rowHeight = calculatedRowHeight
        skeletonDataSource = dataSource

        if let originalDelegate = delegate as? SkeletonTableViewDelegate,
           !(originalDelegate is SkeletonCollectionDelegate)
        {
            let delegate = SkeletonCollectionDelegate(tableViewDelegate: originalDelegate)
            skeletonDelegate = delegate
        }

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
        restoreRowHeight()
        skeletonDataSource = nil
        self.dataSource = dataSource.originalTableViewDataSource

        if let delegate = self.delegate as? SkeletonCollectionDelegate {
            skeletonDelegate = nil
            self.delegate = delegate.originalTableViewDelegate
        }

        if reloadAfter { reloadData() }
    }

    private func restoreRowHeight() {
        guard let dataSource = self.dataSource as? SkeletonCollectionDataSource else { return }
        rowHeight = dataSource.originalRowHeight
    }

    private func calculateRowHeight() -> CGFloat {
        guard rowHeight == UITableView.automaticDimension else { return rowHeight }
        return estimatedRowHeight
    }
}
