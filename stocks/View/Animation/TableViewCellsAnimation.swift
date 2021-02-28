//
//  TableViewCellsAnimation.swift
//  stocks
//
//  Created by Kirill Kostarev on 28.02.2021.
//

import UIKit

// MARK: - Implementation of the default UITableViewCell appearance animation

public func firstAppearanceCell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath, for tableView: UITableView!, checkFor finishedLoadingInitialTableCells: Bool) -> Bool {
    var finishedLoadingInitialTableCells = finishedLoadingInitialTableCells
    var lastInitialDisplayableCell = false
    if !finishedLoadingInitialTableCells {
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
           let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row
        {
            lastInitialDisplayableCell = true
        }
    }
    if !finishedLoadingInitialTableCells {
        if lastInitialDisplayableCell {
            finishedLoadingInitialTableCells = true
        }
        cell.transform = CGAffineTransform(translationX: 0.5, y: 0.5)
        cell.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.alpha = 1
        }, completion: nil)
    }
    return finishedLoadingInitialTableCells
}
