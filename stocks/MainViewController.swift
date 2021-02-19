//
//  ViewController.swift
//  stocks
//
//  Created by Kirill Kostarev on 17.02.2021.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var stocksSelectButton: UIButton! {
        didSet {
            stocksSelectButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 17)
            stocksSelectButton.titleLabel?.tintColor = .black
        }
    }
    @IBOutlet weak var favouriteSelectLabel: UIButton! {
        didSet {
            favouriteSelectLabel.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 17)
            favouriteSelectLabel.titleLabel?.tintColor = .black
        }
    }
    @IBOutlet weak var mainTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainTableViewCell") as! MainTableViewCell
        cell.stockImage.image = UIImage(named: "YNDX")
        cell.stockName.text = "YNDX"
        cell.stockPrice.text = "4 764,6 ₽"
        cell.stockInfo.text = "+55 ₽ (1,15%)"
        cell.stockCompanyName.text = "Yandex, LLC"
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 != 0 {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor(rgb: 0xF0F4F7)
        }
    }
}
