//
//  TableViewCellsAnimation.swift
//  stocks
//
//  Created by Kirill Kostarev on 28.02.2021.
//

import UIKit

// MARK: - UITableVIew

extension UITableView {
    /// Simple UITableView reload data but with cross dissolve transition
    func reloadDataWithAnimation() {
        UIView.transition(with: self, duration: 0.35, options: .transitionCrossDissolve, animations: { self.reloadData() }, completion: nil)
    }
}
