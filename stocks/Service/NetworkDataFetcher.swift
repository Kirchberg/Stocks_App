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
        var mostActiveStock = json["mostActiveStock"]
        for index in 0 ..< 10 {
            let stock = Stock(stockImageURL: "https://financialmodelingprep.com/image-stock/\(mostActiveStock[index]["ticker"].stringValue).png", stockTicker: mostActiveStock[index]["ticker"].stringValue,
                              stockCompanyName: mostActiveStock[index]["companyName"].stringValue,
                              stockPrice: mostActiveStock[index]["price"].stringValue.roundToTwoSymbols(),
                              stockInfo: "\(mostActiveStock[index]["changes"].stringValue.roundToTwoSymbols()) \(mostActiveStock[index]["changesPercentage"].stringValue)")
            stocks.append(stock)
        }
        return stocks
    }

    func search(searchText: String, completion: @escaping ([Stock?]) -> Void) {
        let urlString: String = "https://financialmodelingprep.com/api/v3/search?query=\(searchText)&limit=10&exchange=NASDAQ&apikey=b2859da1e61df36a04795a628e792d69"

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
            completion(self.transferJsonToSearchStocksModel(json: jsonObject))
        }
    }

    private func transferJsonToSearchStocksModel(json: JSON) -> [Stock?] {
        var stocks = [Stock]()
        for index in 0 ..< json.count {
            let stock = Stock(stockImageURL: "https://financialmodelingprep.com/image-stock/\(json[index]["symbol"].stringValue).png", stockTicker: json[index]["symbol"].stringValue,
                              stockCompanyName: json[index]["name"].stringValue,
                              stockPrice: "",
                              stockInfo: "")
            stocks.append(stock)
        }
        return stocks
    }
}
