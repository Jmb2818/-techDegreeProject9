//
//  UIViewController+Extension.swift
//  Proximity
//
//  Created by Joshua Borck on 7/11/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Function for any UIViewController to present a UIAlert with an optional title and non optional message
    func showAlert(title: String?, message: String) {
        let errorTitle = title ?? "Error"
        let alert = UIAlertController(title: errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
