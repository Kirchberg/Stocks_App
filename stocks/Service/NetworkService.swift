//
//  DataFetcher.swift
//  stocks
//
//  Created by Kirill Kostarev on 22.02.2021.
//

import Foundation

/// Class to make request from API
class NetworkService {
    /// Function to request objects from API
    func requestAllStocks(urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = createDataTask(request: request, completion: completion)
        task.resume()
    }

    private func createDataTask(request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
    }
}
