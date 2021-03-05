//
//  StockModel.swift
//  stocks
//
//  Created by Kirill Kostarev on 22.02.2021.
//

import Foundation

class Stock: Decodable, Hashable {
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.stockCompanyName == rhs.stockCompanyName && lhs.stockTicker == rhs.stockTicker
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stockCompanyName)
        hasher.combine(stockTicker)
    }

    var stockImageURL: String?
    var stockTicker: String
    var stockCompanyName: String
    var stockPrice: String
    var stockInfo: String
    var stockFavourite: Bool

    init(stockImageURL: String?, stockTicker: String, stockCompanyName: String, stockPrice: String, stockInfo: String, stockFavourite: Bool = false) {
        self.stockImageURL = stockImageURL
        self.stockTicker = stockTicker
        self.stockCompanyName = stockCompanyName
        self.stockPrice = stockPrice
        self.stockInfo = stockInfo
        self.stockFavourite = stockFavourite
    }
}
