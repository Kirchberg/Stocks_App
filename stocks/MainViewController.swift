//
//  ViewController.swift
//  stocks
//
//  Created by Kirill Kostarev on 17.02.2021.
//

import UIKit

class MainViewController: UIViewController {
    // MARK: - Variables

    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }

    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

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
        }
    }

    // MARK: - View Controller functions

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.searchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 17)
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.sizeToFit()
    }
}

// MARK: - UITableViewDataSource(Skeleton of mainTableView)

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainTableViewCell") as! MainTableViewCell
        cell.layer.cornerRadius = 15.0
        cell.stockImage.image = UIImage(named: "YNDX")
        cell.stockName.text = "YNDX"
        cell.stockPrice.text = "4 764,6 ₽"
        cell.stockInfo.text = "+55 ₽ (1,15%)"
        cell.stockCompanyName.text = "Yandex, LLC"
        return cell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 10
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
