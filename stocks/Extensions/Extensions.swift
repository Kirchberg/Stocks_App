//
//  Extensions.swift
//  stocks
//
//  Created by Kirill Kostarev on 19.02.2021.
//

import RealmSwift
import UIKit

// MARK: - UIColor extension for tableView cells

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

// MARK: - String

extension String {
    /// Round the number after the decimal point to two digits
    mutating func roundToTwoSymbols() -> String {
        if let self = Double(self) {
            return String(format: "%.2f", self)
        } else {
            return self
        }
    }

    func isEmpty() -> Bool {
        let str = filter { !" ".contains($0) }
        return (str == "") ? true : false
    }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}

// MARK: - Array

/// Remove duplicates from array
extension Array where Element: Hashable {
    /// Remove duplicates from array
    var orderedSet: Array {
        var unique = Set<Element>()
        return filter { element in
            unique.insert(element).inserted
        }
    }
}

extension Array where Element == Stock? {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard let itemStockTicker = item?.stockTicker else { return }
            guard !uniqueValues.contains(where: { (stock) -> Bool in
                guard let stockTicker = stock?.stockTicker else { return false }
                return stockTicker.contains(itemStockTicker)
            }) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}

/// Remove element from array
extension Array where Element: Equatable {
    /// Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
    }

    func contains(array: [Stock]) -> Bool {
        for item in array {
            if !contains(item.stockTicker as! Element) { return false }
        }
        return true
    }
}

extension Results {
    /// Convert Realm Results to array
    func toArray() -> [Element] {
        return compactMap {
            $0
        }
    }
}
