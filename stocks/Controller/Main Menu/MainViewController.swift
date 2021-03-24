//
//  ViewController.swift
//  stocks
//
//  Created by Kirill Kostarev on 17.02.2021.
//

import Kingfisher
import RealmSwift
import SkeletonView
import UIKit

class MainViewController: UIViewController {
    // MARK: - Variables

    private let networkDataFetcher = NetworkDataFetcher()

    private var stocks = [Stock?]()
    private var favouriteStocks: Results<Stock>?
    private var searchResults = [Stock?]() {
        didSet {
            tableView.reloadDataWithAnimation()
        }
    }

    private var isFavourite = false

    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty()
    }

    private weak var searchDelayer: Timer?

    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    private var finishedLoadingInitialTableCells = false

    // MARK: - IBOutlets

    @IBOutlet var stocksSelectButton: UIButton! {
        didSet {
            stocksSelectButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
            stocksSelectButton.titleLabel?.tintColor = .black
            stocksSelectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet var favouriteSelectButton: UIButton! {
        didSet {
            favouriteSelectButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 17)
            favouriteSelectButton.titleLabel?.tintColor = UIColor(rgb: 0xBABABA)
            favouriteSelectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .none
            tableView.backgroundColor = .white
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableView.automaticDimension
        }
    }

    // MARK: - View Controller functions

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        favouriteStocks = realm.objects(Stock.self)
        tableView.isSkeletonable = true
        startFetchingStocks()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.showAnimatedGradientSkeleton()
        view.startSkeletonAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "SMD – Stocks"
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 20)!]
    }

    // MARK: - IBActions buttons

    @IBAction func favouriteButtonClicked(_: UIButton) {
        changeStyleOfButtons(disable: stocksSelectButton, enable: favouriteSelectButton)
        isFavourite = true
        tableView.reloadDataWithAnimation()
    }

    @IBAction func stocksButtonClicked(_: UIButton) {
        changeStyleOfButtons(disable: favouriteSelectButton, enable: stocksSelectButton)
        isFavourite = false
        tableView.reloadDataWithAnimation()
    }

    /// Function that responsible for logic favourite button
    @IBAction func addStockToFavourite(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)

        guard let row = indexPath?.row else {
            return
        }

        // If we are searching stocks via searchBar
        if isFiltering {
            guard let stockFromSearch = searchResults[row] else { return }

            // If we need to check if stock is in favourite
            if stockFromSearch.stockFavourite {
                // Set to false if we tapped button
                stockFromSearch.stockFavourite = false
                sender.setImage(UIImage(named: "favouriteNonSelected"), for: .normal)
                StorageManager.deleteStockObject(stockFromSearch)
                if let stock = stocks.first(where: { $0?.stockTicker == stockFromSearch.stockTicker }) {
                    stock?.stockFavourite = false
                }
            } else {
                // If it's not set favourite to true
                stockFromSearch.stockFavourite = true
                sender.setImage(UIImage(named: "favouriteSelected"), for: .normal)
                let favouriteStock = Stock(stockImageURL: stockFromSearch.stockImageURL,
                                           stockTicker: stockFromSearch.stockTicker,
                                           stockCompanyName: stockFromSearch.stockCompanyName,
                                           stockPrice: stockFromSearch.stockPrice,
                                           stockCurrency: stockFromSearch.stockCurrency,
                                           stockInfo: stockFromSearch.stockInfo,
                                           stockFavourite: stockFromSearch.stockFavourite)
                StorageManager.saveStockObject(favouriteStock)
            }
        } else {
            // If we are in favourite tab
            if isFavourite {
                // Then just simply delete from phone information about stock
                guard let favouriteElem = favouriteStocks?[row] else { return }
                guard let stockFavouriteTicker = favouriteElem.stockTicker else { return }
                if let stock = stocks.first(where: { $0?.stockTicker == stockFavouriteTicker }) {
                    stock?.stockFavourite = false
                }
                StorageManager.deleteStockObject(favouriteElem)
                tableView.reloadDataWithAnimation()
            } else if !isFavourite {
                // Else we are on main menu
                guard let stock = stocks[row] else { return }

                // If we need to check if stock is in favourite
                if stock.stockFavourite {
                    // Set to false if we tapped button
                    stock.stockFavourite = false
                    sender.setImage(UIImage(named: "favouriteNonSelected"), for: .normal)
                    StorageManager.deleteStockObject(stock)
                } else {
                    // If it's not set favourite to true
                    stock.stockFavourite = true
                    let favouriteStock = Stock(stockImageURL: stock.stockImageURL,
                                               stockTicker: stock.stockTicker,
                                               stockCompanyName: stock.stockCompanyName,
                                               stockPrice: stock.stockPrice,
                                               stockCurrency: stock.stockCurrency,
                                               stockInfo: stock.stockInfo,
                                               stockFavourite: stock.stockFavourite)
                    sender.setImage(UIImage(named: "favouriteSelected"), for: .normal)
                    StorageManager.saveStockObject(favouriteStock)
                }
            }
        }
    }

    // MARK: - Private functions

    /// Change style of buttons when they were clicked
    private func changeStyleOfButtons(disable firstButton: UIButton, enable secondButton: UIButton) {
        firstButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 17)
        firstButton.titleLabel?.tintColor = UIColor(rgb: 0xBABABA)
        firstButton.titleLabel?.adjustsFontSizeToFitWidth = true
        secondButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
        secondButton.titleLabel?.tintColor = .black
        secondButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    private func configureUI() {
        configureSearchController()
    }

    private func configureSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.searchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 18)
        searchController.searchBar.setImage(UIImage(named: "Find"), for: .search, state: .normal)
        searchController.searchBar.setImage(UIImage(named: "Cancel"), for: .clear, state: .normal)
        searchController.searchBar.searchTextField.layer.cornerRadius = 13
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.layer.borderColor = UIColor.black.cgColor
        searchController.searchBar.searchTextField.layer.borderWidth = 1
        searchController.searchBar.tintColor = .black
        searchController.searchBar.sizeToFit()
    }

    /// Function to find stock object in some array
    private func findStock(find key: String, in array: [Stock?]) -> (isStockExist: Bool, matchStock: Stock?) {
        guard key != "" else { return (false, nil) }
        let filteredArray = array.filter { (stock: Stock?) -> Bool in
            if let stock = stock {
                guard let stockTicker = stock.stockTicker else { return false }
                return stockTicker.lowercased().elementsEqual(key.lowercased())
            } else {
                return false
            }
        }
        guard let stock = filteredArray.first else { return (false, nil) }
        return (!filteredArray.isEmpty, stock)
    }

    /// Function to check if some stocks from favourite is already exists in fetched array from API
    private func checkForExistingStocks(in stocksData: [Stock?]) {
        guard let favouriteStocks = favouriteStocks else { return }
        guard favouriteStocks.count > 0 else { return }
        stocksData.forEach { stock in
            guard let stock = stock else { return }

            if favouriteStocks.contains(where: { (favouriteStock) -> Bool in
                favouriteStock.stockTicker == stock.stockTicker
            }) {
                stock.stockFavourite = true
                let favouriteStock = Stock(stockImageURL: stock.stockImageURL,
                                           stockTicker: stock.stockTicker,
                                           stockCompanyName: stock.stockCompanyName,
                                           stockPrice: stock.stockPrice,
                                           stockCurrency: stock.stockCurrency,
                                           stockInfo: stock.stockInfo,
                                           stockFavourite: stock.stockFavourite)
                StorageManager.saveStockObject(favouriteStock)
            }
        }
    }

    /// Function to fetch most active stocks from API
    private func setStockData(_ finishDataTask: @escaping () -> Void) {
        let group = DispatchGroup()
        let dispatchQueue = DispatchQueue.global(qos: .default)
        let semaphore = DispatchSemaphore(value: 0)

        // Retrieve general data about most active stocks from API
        dispatchQueue.async(group: group) {
            let urlString: String = FMP.mostActiveStocksURL
            self.networkDataFetcher.fetchAllStocks(urlString: urlString) { stocksData in
                self.stocks = stocksData
                semaphore.signal()
            }

            semaphore.wait()

            // Retreive currency of fetched most active stocks due to not possible to get from first request because of restrictions in API
            semaphore.signal()
            for stock in self.stocks {
                guard let stock = stock else { return }
                guard let stockTicker = stock.stockTicker else {
                    semaphore.signal()
                    return
                }
                let urlString = FMP.createCompanyProfileURL(for: stockTicker, isSearching: false)

                self.networkDataFetcher.fetchStocksCurrency(urlString: urlString) { stockWithCurrency in
                    guard let stockWithCurrency = stockWithCurrency else { return }
                    guard let stockCurrency = stockWithCurrency.stockCurrency else { return }
                    stock.stockCurrency = CurrencyConverter.getSymbol(forCurrencyCode: stockCurrency)
                    stock.stockFullPrice = "\(stock.stockCurrency ?? "$")\(stock.stockPrice ?? "")"
                    semaphore.signal()
                }
                semaphore.wait()
            }
            semaphore.wait()
            finishDataTask()
        }
    }

    private func startFetchingStocks() {
        setStockData {
            DispatchQueue.main.async {
                self.checkForExistingStocks(in: self.stocks)
                self.view.stopSkeletonAnimation()
                self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            }
        }
    }
}

// MARK: - UITableViewDataSource(Skeleton of mainTableView), SkeletonTableViewDataSource

extension MainViewController: SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier) as! MainTableViewCell
        let filteredStocks = isFiltering ? searchResults[indexPath.row] : (!isFavourite ? stocks[indexPath.row] : favouriteStocks?[indexPath.row])
        if let stock = filteredStocks {
            cell.layer.cornerRadius = 16.0

            let resource = ImageResource(downloadURL: URL(string: stock.stockImageURL!)!, cacheKey: stock.stockImageURL)
            cell.stockImage.kf.setImage(with: resource, placeholder: UIImage(named: "empty_logo"), options: [.transition(.fade(0.7))], progressBlock: nil)

            cell.stockTicker.text = stock.stockTicker

            if !stock.stockFavourite {
                cell.favouriteButton.setImage(UIImage(named: "favouriteNonSelected"), for: .normal)
            } else {
                cell.favouriteButton.setImage(UIImage(named: "favouriteSelected"), for: .normal)
            }

            cell.stockCompanyName.text = stock.stockCompanyName
            cell.stockPrice.text = stock.stockFullPrice
            cell.stockInfo.text = stock.stockInfo

            if cell.stockInfo.text?.contains("+") == true {
                cell.stockInfo.textColor = UIColor(rgb: 0x24B25D)
                if let startIndex = cell.stockInfo.text?.startIndex {
                    cell.stockInfo.text?.insert(contentsOf: "+\(stock.stockCurrency ?? "+$")", at: startIndex)
                }
            } else {
                cell.stockInfo.textColor = UIColor(rgb: 0xB22424)
                if let startIndex = cell.stockInfo.text?.startIndex {
                    cell.stockInfo.text?.insert(contentsOf: "\(stock.stockCurrency ?? "$")", at: cell.stockInfo.text?.index(startIndex, offsetBy: 1) ?? startIndex)
                }
            }
        }
        return cell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return isFiltering ? searchResults.count : (!isFavourite ? stocks.count : favouriteStocks?.count ?? 0)
    }

    func collectionSkeletonView(_: UITableView, cellIdentifierForRowAt _: IndexPath) -> ReusableCellIdentifier {
        return MainTableViewCell.identifier
    }
}

// MARK: - UITableViewDelegate (Customization of mainTableView)

extension MainViewController: UITableViewDelegate {
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 != 0 {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor(red: 0.941, green: 0.955, blue: 0.97, alpha: 1)
        }

        finishedLoadingInitialTableCells = firstAppearanceCell(cell, forRowAt: indexPath, for: tableView, checkFor: finishedLoadingInitialTableCells)
    }
}

// MARK: - UISearchControllerDelegate

extension MainViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.autocorrectionType = .no
        searchController.hidesNavigationBarDuringPresentation = true
    }
}

extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for _: UISearchController) {}

    /// Function to search stocks by ticker or company name
    private func searchStocksByTickerOrCompanyName(_ searchController: UISearchController) -> [Stock?] {
        let searchText = searchController.searchBar.text
        var tempSearchResultsByStockTicker = stocks.filter { stock in
            guard let stock = stock else { return false }
            guard let stockTicker = stock.stockTicker else { return false }
            return stockTicker.lowercased().contains(searchText!.lowercased())
        }
        let tempSearchResultsByCompanyName = stocks.filter { stock in
            guard let stock = stock else { return false }
            guard let stockCompanyName = stock.stockCompanyName else { return false }
            return stockCompanyName.lowercased().contains(searchText!.lowercased())
        }
        tempSearchResultsByStockTicker.append(contentsOf: tempSearchResultsByCompanyName)
        return tempSearchResultsByStockTicker
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        // Destroy timer for input text from searchBar
        searchDelayer?.invalidate()
        searchDelayer = nil
        if !isSearchBarEmpty {
            favouriteSelectButton.isHidden = true
            UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.stocksSelectButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18)
                self.stocksSelectButton.titleLabel?.tintColor = .black
                self.stocksSelectButton.titleLabel?.adjustsFontSizeToFitWidth = true
                self.stocksSelectButton.isUserInteractionEnabled = false
            }, completion: nil)
            searchResults = searchStocksByTickerOrCompanyName(searchController).orderedSet
            // After the timer has expired timeInterval, start fetch stocks by searchText
            searchDelayer = Timer.scheduledTimer(timeInterval: 1.0,
                                                 target: self,
                                                 selector: #selector(filterContentForSearchText(_:)),
                                                 userInfo: searchText,
                                                 repeats: false)
        } else {
            searchResults = stocks
        }
    }

    /// Function to retrieve data from text in search bar
    @objc func filterContentForSearchText(_ t: Timer) {
        // If timer expires, then start
        if t == searchDelayer {
            let group = DispatchGroup()
            let dispatchQueue = DispatchQueue.global(qos: .background)
            let semaphore = DispatchSemaphore(value: 0)

            var searchStocksData = [Stock?]()

            guard let searchText = searchDelayer?.userInfo as? String else { return }

            if !searchText.isEmpty() {
                // Retrieve general data (ticker, company name) that match to searchText
                dispatchQueue.async(group: group) {
                    self.networkDataFetcher.searchStocksData(for: searchText) {
                        resultData in
                        searchStocksData = resultData
                        for stock in searchStocksData {
                            guard let stockTicker = stock?.stockTicker else {
                                semaphore.signal()
                                return
                            }

                            // Find stocks that already exists in main menu
                            let tupleStocks = self.findStock(find: stockTicker, in: self.stocks)

                            // If we have them, then remove searched data
                            if tupleStocks.isStockExist {
                                searchStocksData.removeAll {
                                    $0?.stockTicker == tupleStocks.matchStock?.stockTicker
                                }
                            }

                            // Find stocks that already exists in favourite
                            if let favouriteStocksArray = self.favouriteStocks?.toArray() {
                                let tupleFavouriteStocks = self.findStock(find: stockTicker, in: favouriteStocksArray)

                                // If we have them, then set to favourite in searched resuls
                                if tupleFavouriteStocks.isStockExist {
                                    if let stock = searchStocksData.first(where: { $0?.stockTicker == tupleFavouriteStocks.matchStock?.stockTicker }) {
                                        stock?.stockFavourite = true
                                    }
                                }
                            }
                        }
                        semaphore.signal()
                    }

                    semaphore.wait()

                    // Retrieve other important information (price, currency and information) about fetched stocks
                    semaphore.signal()
                    for stock in searchStocksData {
                        guard let stock = stock else { return }
                        guard let stockTicker = stock.stockTicker else { return }
                        let urlString: String = FMP.createCompanyQuoteURL(for: stockTicker)
                        self.networkDataFetcher.fetchStocksCurrency(urlString: urlString) { stockWithCurrency in
                            guard let stockWithCurrency = stockWithCurrency else {
                                semaphore.signal()
                                return
                            }
                            stock.stockCurrency = "$"
                            stock.stockPrice = stockWithCurrency.stockPrice
                            stock.stockInfo = stockWithCurrency.stockInfo
                            stock.stockFullPrice = "\(stock.stockCurrency ?? "")\(stock.stockPrice ?? "")"
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    semaphore.wait()

                    DispatchQueue.main.async {
                        self.searchResults.append(contentsOf: searchStocksData)
                        self.searchResults.removeAll { stock in
                            guard let stock = stock else { return false }
                            guard let stockInfo = stock.stockInfo else { return false }
                            guard let stockPrice = stock.stockPrice else { return false }
                            return (stockPrice == "") || (stockInfo == "") || stockInfo.contains("0.0")
                        }
                        self.searchResults = self.searchResults.orderedSet
                        self.searchDelayer = nil
                    }
                }
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stocksSelectButton.isUserInteractionEnabled = true
        favouriteSelectButton.isHidden = false
        stocksSelectButton.sendActions(for: .touchUpInside)
        searchBar.text = nil
        searchResults.removeAll()
    }
}
