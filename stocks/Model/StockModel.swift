//
//  StockModel.swift
//  stocks
//
//  Created by Kirill Kostarev on 22.02.2021.
//

import Foundation

class Stock: Decodable {
    var stockImage: Data?
    var stockTicker: String
    var stockCompanyName: String
    var stockPrice: String
    var stockInfo: String
    var stockFavourite: Bool

    init(stockImage: Data? = nil, stockTicker: String, stockCompanyName: String, stockPrice: String, stockInfo: String, stockFavourite: Bool = false) {
        self.stockImage = stockImage
        self.stockTicker = stockTicker
        self.stockCompanyName = stockCompanyName
        self.stockPrice = stockPrice
        self.stockInfo = stockInfo
        self.stockFavourite = stockFavourite
    }
}
