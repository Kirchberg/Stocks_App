//
//  NetworkDataFetcher.swift
//  stocks
//
//  Created by Kirill Kostarev on 27.02.2021.
//

import Foundation
import SwiftyJSON

class NetworkDataFetcher {
    private var networkService = NetworkService()

    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }

    func fetchAllStocks(urlString: String, completion: @escaping ([Stock?]) -> Void) {
        networkService.requestAllStocks(urlString: urlString) { data, error in
            guard error == nil else {
                return
            }

            guard let dataFromNetworking = data else {
                return
            }

            let jsonObject = try! JSON(data: dataFromNetworking)
            completion(self.transferJsonToStocksModel(json: jsonObject))
        }
    }

    private func transferJsonToStocksModel(json: JSON) -> [Stock?] {
        var stocks = [Stock]()
        var mostActiveStock = json["mostActiveStock"]
        for index in 0 ..< 10 {
            let stock = Stock(stockImageURL: "https://financialmodelingprep.com/image-stock/\(mostActiveStock[index]["ticker"].stringValue).png",
                              stockTicker: mostActiveStock[index]["ticker"].stringValue,
                              stockCompanyName: mostActiveStock[index]["companyName"].stringValue,
                              stockPrice: mostActiveStock[index]["price"].stringValue.roundToTwoSymbols(),
                              stockInfo: "\(mostActiveStock[index]["changes"].stringValue.roundToTwoSymbols()) \(mostActiveStock[index]["changesPercentage"].stringValue)")
            stocks.append(stock)
        }
        return stocks
    }

    func fetchStocksCurrency(urlString: String, completion: @escaping (Stock?) -> Void) {
        networkService.requestAllStocks(urlString: urlString) { data, error in
            guard error == nil else {
                return
            }

            guard let dataFromNetworking = data else {
                return
            }

            let json = try! JSON(data: dataFromNetworking)
            completion(self.transferJsonToCurrencyStockModel(jsonObject: json))
        }
    }

    private func transferJsonToCurrencyStockModel(jsonObject: JSON) -> Stock? {
        var json = jsonObject
        var stock: Stock?
        if json[0]["changesPercentage"].stringValue.contains("-") {
            stock = Stock(stockPrice: json[0]["price"].stringValue.roundToTwoSymbols(),
                          stockCurrency: json[0]["currency"].stringValue,
                          stockInfo: "\(json[0]["change"].stringValue) (\(json[0]["changesPercentage"].stringValue)%)")
        } else {
            stock = Stock(stockPrice: json[0]["price"].stringValue.roundToTwoSymbols(),
                          stockCurrency: json[0]["currency"].stringValue,
                          stockInfo: "\(json[0]["change"].stringValue) (+\(json[0]["changesPercentage"].stringValue)%)")
        }
        return stock
    }

    // MARK: - Search

    /// Search function to retrieve data from search bar
    func searchStocksData(for searchText: String, completion: @escaping ([Stock?]) -> Void) {
        let urlString: String = FMP.createTickerSearchURL(for: searchText)

        networkService.requestAllStocks(urlString: urlString) { data, error in
            guard error == nil else {
                return
            }

            guard let dataFromNetworking = data else {
                return
            }

            let jsonObject = try! JSON(data: dataFromNetworking)
            completion(self.transferJsonToSearchStocksModel(json: jsonObject))
        }
    }

    private func transferJsonToSearchStocksModel(json: JSON) -> [Stock?] {
        var stocks = [Stock]()
        for index in 0 ..< json.count {
            let stock = Stock(stockImageURL: "https://financialmodelingprep.com/image-stock/\(json[index]["symbol"].stringValue).png",
                              stockTicker: json[index]["symbol"].stringValue,
                              stockCompanyName: json[index]["name"].stringValue,
                              stockCurrency: "$")
            stocks.append(stock)
        }
        return stocks
    }
}
