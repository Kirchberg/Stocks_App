//
//  SwiftAlertView.swift
//  stocks
//
//  Created by Kirill Kostarev on 26.03.2021.
//

import Foundation
import PMAlertController

/// Struct to generate Custom UIAlertController
struct CustomAlertView {
    ///Function to show error message
    static func showError(title: String, description: String, present: @escaping (PMAlertController) -> Void) {
        let alertVC = PMAlertController(title: title, description: description, image: UIImage(named: "no_result"), style: .alert)

        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: nil))

        present(alertVC)
    }
}
