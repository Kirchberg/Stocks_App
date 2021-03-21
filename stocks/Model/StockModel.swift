//
//  StockModel.swift
//  stocks
//
//  Created by Kirill Kostarev on 22.02.2021.
//

import Foundation
import RealmSwift

class Stock: Object {
    @objc dynamic var stockImageURL: String? = ""
    @objc dynamic var stockTicker: String? = ""
    @objc dynamic var stockCompanyName: String? = ""
    @objc dynamic var stockPrice: String? = ""
    @objc dynamic var stockCurrency: String? = ""
    @objc dynamic var stockFullPrice: String? = ""
    @objc dynamic var stockInfo: String? = ""
    @objc dynamic var stockFavourite: Bool = false

    convenience init(stockImageURL: String? = "", stockTicker: String? = "", stockCompanyName: String? = "", stockPrice: String? = "", stockCurrency: String? = "", stockInfo: String? = "", stockFavourite: Bool = false) {
        self.init()
        self.stockImageURL = stockImageURL
        self.stockTicker = stockTicker
        self.stockCompanyName = stockCompanyName
        self.stockPrice = stockPrice
        self.stockCurrency = stockCurrency
        stockFullPrice = "\(stockCurrency ?? "$")\(stockPrice ?? "")"
        self.stockInfo = stockInfo
        self.stockFavourite = stockFavourite
    }
}
