//
//  ViewController.swift
//  stocks
//
//  Created by Kirill Kostarev on 17.02.2021.
//

import Kingfisher
import SkeletonView
import UIKit

class MainViewController: UIViewController {
    // MARK: - Variables

    private let urlStocksDataFMP = "https://financialmodelingprep.com/api/v3/stock/actives?apikey=fb14a5b3ada99d60c4b727f546595edb"

    private let networkDataFetcher = NetworkDataFetcher()

    private var stocks = [Stock?]()
    private var favouriteStocks = [Stock?]()

    private var isFavourite = false

    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }

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
            self.tableView.rowHeight = UITableView.automaticDimension
        }
    }

    // MARK: - View Controller functions

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tableView.isSkeletonable = true
        networkDataFetcher.fetchAllStocks(urlString: urlStocksDataFMP) { stocksData in
            self.stocks = stocksData
            // TODO: - Get from Finnhub currency
            DispatchQueue.main.async {
                self.view.stopSkeletonAnimation()
                self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            }
        }
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
        tableView.reloadData()
    }

    @IBAction func stocksButtonClicked(_: UIButton) {
        changeStyleOfButtons(disable: favouriteSelectButton, enable: stocksSelectButton)
        isFavourite = false
        tableView.reloadData()
    }

    @IBAction func addStockToFavourite(_ sender: UIButton) {
        var tempFavouriteStocks = favouriteStocks
        let buttonPosition = sender.convert(CGPoint(), to: tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)

        guard let row = indexPath?.row else {
            print("Error: Can't get row")
            return
        }
        guard let stock = !isFavourite ? stocks[row] : favouriteStocks[row] else {
            print("Error: Can't add stock to favourite due to some error")
            return
        }

        if stock.stockFavourite, isFavourite {
            favouriteStocks.remove(at: row)
            stock.stockFavourite = false
            tableView.reloadData()
        } else if stock.stockFavourite, !isFavourite {
            stock.stockFavourite = false
            sender.setImage(UIImage(named: "favouriteNonSelected"), for: .normal)
            tempFavouriteStocks.removeObject(object: stock)
            favouriteStocks = tempFavouriteStocks.orderedSet
        } else {
            stock.stockFavourite = true
            sender.setImage(UIImage(named: "favouriteSelected"), for: .normal)
            tempFavouriteStocks.append(stock)
            favouriteStocks = tempFavouriteStocks.orderedSet
            print(stock.stockCompanyName)
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
}

// MARK: - UITableViewDataSource(Skeleton of mainTableView), SkeletonTableViewDataSource

extension MainViewController: SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier) as! MainTableViewCell
        let filteredStocks = !isFavourite ? stocks[indexPath.row] : favouriteStocks[indexPath.row]
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
            cell.stockPrice.text = stock.stockPrice
            cell.stockInfo.text = stock.stockInfo

            if cell.stockInfo.text?.contains("+") == true {
                cell.stockInfo.textColor = UIColor(rgb: 0x24B25D)
            } else {
                cell.stockInfo.textColor = UIColor(rgb: 0xB22424)
            }
        }
        return cell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return !isFavourite ? stocks.count : favouriteStocks.count
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

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    // TODO: - Filter by company name or ticker
    private func filterContentForSearchText(_: String) {
        tableView.reloadData()
    }
}
