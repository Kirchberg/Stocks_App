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
                print(error!)
                return
            }

            guard let dataFromNetworking = data else {
                print("Data is empty")
                return
            }

            let jsonObject = try! JSON(data: dataFromNetworking)
            completion(self.transferJsonToStocksModel(json: jsonObject))
        }
    }

    private func transferJsonToStocksModel(json: JSON) -> [Stock?] {
        var stocks = [Stock]()
        // TODO: - Сделать ограничение в два символа в валюте и изменениях после запятой
        let mostActiveStock = json["mostActiveStock"]
        for index in 0 ..< mostActiveStock.count {
            let stock = Stock(stockImageURL: "https://finnhub.io/api/logo?symbol=\(mostActiveStock[index]["ticker"].stringValue)", stockTicker: mostActiveStock[index]["ticker"].stringValue,
                              stockCompanyName: mostActiveStock[index]["companyName"].stringValue,
                              stockPrice: mostActiveStock[index]["price"].stringValue,
                              stockInfo: "\(mostActiveStock[index]["changes"].stringValue) \(mostActiveStock[index]["changesPercentage"].stringValue)")
            stocks.append(stock)
        }
        return stocks
    }
}
