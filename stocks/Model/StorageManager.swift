//
//  StorageManager.swift
//  stocks
//
//  Created by Kirill Kostarev on 25.02.2021.
//

import Foundation
import RealmSwift

let realm = try! Realm()

/// Enum that provides methods to edit model
enum StorageManager {
    /// Save stock to DB
    /// - Parameter stock: Object to save in realm
    static func saveStockObject(_ stock: Stock) {
        guard let stockTicker = stock.stockTicker else {
            print("Error: Can't delete object with name \(stock.stockTicker ?? "")")
            return
        }
        let predicate = NSPredicate(format: "stockTicker == %@", stockTicker)
        let array = realm.objects(Stock.self).filter(predicate)
        try! realm.write {
            if array.count == 0 {
                realm.add(stock)
            } else {
                StorageManager.updateStockObject(update: stock, to: array.first!)
            }
        }
    }

    /// Delete stock from DB
    /// - Parameter stock: Object to delete from realm
    static func deleteStockObject(_ stock: Stock) {
        guard let stockTicker = stock.stockTicker else {
            print("Error: Can't delete object with name \(stock.stockTicker ?? "")")
            return
        }
        let predicate = NSPredicate(format: "stockTicker == %@", stockTicker)
        try! realm.write {
            if let productToDelete = realm.objects(Stock.self).filter(predicate).first {
                realm.delete(productToDelete)
            }
        }
    }

    /// Update stock with new info
    static func updateStockObject(update oldInfostock: Stock, to newInfostock: Stock) {
        try! realm.write {
            oldInfostock.stockFavourite = newInfostock.stockFavourite
            oldInfostock.stockPrice = newInfostock.stockPrice
            oldInfostock.stockInfo = newInfostock.stockInfo
        }
    }
}
