//
//  MainTableViewCell.swift
//  stocks
//
//  Created by Kirill Kostarev on 17.02.2021.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var stockImage: UIImageView! {
        didSet {
            stockImage.layer.masksToBounds = true
            stockImage.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet weak var stockName: UILabel! {
        didSet {
            stockName.font = UIFont(name: "Montserrat-Bold", size: 18)
            stockName.textColor = .black
        }
    }
    @IBOutlet weak var stockCompanyName: UILabel! {
        didSet {
            stockCompanyName.font = UIFont(name: "Montserrat-Medium", size: 14)
            stockCompanyName.textColor = .black
        }
    }
    @IBOutlet weak var favouriteButton: UIButton! {
        didSet {
            favouriteButton.titleLabel?.text = nil
            favouriteButton.setImage(UIImage(named: "favouriteNonSelected"), for: .normal)
        }
    }
    @IBOutlet weak var stockPrice: UILabel! {
        didSet {
            stockPrice.font = UIFont(name: "Montserrat-Bold", size: 18)
            stockPrice.textColor = .black
        }
    }
    @IBOutlet weak var stockInfo: UILabel! {
        didSet {
            stockInfo.font = UIFont(name: "Montserrat-Medium", size: 14)
            stockInfo.textColor = .black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addToFavouriteStock(_ sender: UIButton) {
    }
}
