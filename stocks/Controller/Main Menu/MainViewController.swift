//
//  ViewController.swift
//  stocks
//
//  Created by Kirill Kostarev on 17.02.2021.
//

import SkeletonView
import UIKit

class MainViewController: UIViewController {
    // MARK: - Variables

    private let urlStocksDataFMP = "https://financialmodelingprep.com/api/v3/stock/actives?apikey=fb14a5b3ada99d60c4b727f546595edb"

    private let networkDataFetcher = NetworkDataFetcher()
    private var stocks = [Stock?]()

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

    @IBOutlet var mainTableView: UITableView! {
        didSet {
            mainTableView.separatorStyle = .none
            mainTableView.backgroundColor = .white
            mainTableView.rowHeight = UITableView.automaticDimension
            mainTableView.estimatedRowHeight = 69
        }
    }

    // MARK: - View Controller functions

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        mainTableView.isSkeletonable = true
        networkDataFetcher.fetchAllStocks(urlString: urlStocksDataFMP) { stocksData in
            self.stocks = stocksData
            self.view.stopSkeletonAnimation()
            self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.showAnimatedGradientSkeleton()
        view.startSkeletonAnimation()
    }

    // MARK: - IBActions buttons

    @IBAction func favouriteButtonClicked(_: UIButton) {
        changeStyleOfButtons(disable: stocksSelectButton, enable: favouriteSelectButton)
    }

    @IBAction func stocksButtonClicked(_: UIButton) {
        changeStyleOfButtons(disable: favouriteSelectButton, enable: stocksSelectButton)
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
        if let stock = stocks[indexPath.row] {
            cell.layer.cornerRadius = 15.0
            cell.stockImage.image = UIImage(named: "YNDX")
            cell.stockTicker.text = stock.stockTicker
            cell.stockPrice.text = stock.stockPrice
            cell.stockInfo.text = stock.stockInfo
            cell.stockCompanyName.text = stock.stockCompanyName
        }
        return cell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return stocks.count
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
            cell.backgroundColor = UIColor(rgb: 0xF0F4F7)
        }

        finishedLoadingInitialTableCells = firstAppearanceCell(cell, forRowAt: indexPath, for: mainTableView, checkFor: finishedLoadingInitialTableCells)
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

    // TODO: - Filter by company name or ticker(stock name)
    private func filterContentForSearchText(_: String) {
        mainTableView.reloadData()
    }
}
