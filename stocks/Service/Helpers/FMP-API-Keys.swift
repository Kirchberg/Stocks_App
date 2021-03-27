//
//  FMP-API-Keys.swift
//  stocks
//
//  Created by Kirill Kostarev on 23.03.2021.
//

import Foundation

/// Struct for providing functions to an application from the FMP API
struct FMP {
    private enum apiKeys: String {
        case companyQuote = "?apikey=afc2860bd1a047f755cfe91cb6487b5b"
        case companyProfileMain = "?apikey=b2859da1e61df36a04795a628e792d69"
        case companyProfileSearch = "?apikey=c8b76a0d432f5731c564f36f4911bdfc"
        case tickerSearch = "&limit=10&exchange=NASDAQ&apikey=3d682b15093addc2b3ce3f20249ec11a"
    }

    private static let companyQuote: String = "https://financialmodelingprep.com/api/v3/quote/"
    private static let companyProfle: String = "https://financialmodelingprep.com/api/v3/profile/"
    private static let tickerSearch: String = "https://financialmodelingprep.com/api/v3/search-ticker?query="
    static let mostActiveStocksURL: String = "https://financialmodelingprep.com/api/v3/stock/actives?apikey=fb14a5b3ada99d60c4b727f546595edb"

    static func createCompanyQuoteURL(for stockTicker: String) -> String {
        var URL: String = companyQuote
        URL.append(stockTicker)
        URL.append(FMP.apiKeys.companyQuote.rawValue)
        return URL
    }

    static func createCompanyProfileURL(for stockTicker: String, isSearching: Bool) -> String {
        var URL: String = companyProfle
        URL.append(stockTicker)
        isSearching ? URL.append(FMP.apiKeys.companyProfileSearch.rawValue) : URL.append(FMP.apiKeys.companyProfileMain.rawValue)
        return URL
    }

    static func createTickerSearchURL(for searchText: String) -> String {
        var URL: String = tickerSearch
        URL.append(searchText)
        URL.append(FMP.apiKeys.tickerSearch.rawValue)
        return URL
    }
}
