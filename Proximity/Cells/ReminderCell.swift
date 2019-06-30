//
//  ReminderCell.swift
//  Proximity
//
//  Created by Joshua Borck on 6/26/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var checkedButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reminderView.layer.masksToBounds = false
        reminderView.layer.cornerRadius = 20
        reminderView.layer.shadowOffset = CGSize(width: 0, height: 4)
        reminderView.layer.shadowRadius = 2
        reminderView.layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        reminderView.layer.shadowOpacity = 1
        reminderView.clipsToBounds = false
    }

    func configureAt(_ indexPath: IndexPath, withModel model: ReminderModel) {
        reminderView.backgroundColor = isEven(indexPath.row) ? #colorLiteral(red: 0.8980392157, green: 0.5450980392, blue: 0.5333333333, alpha: 1) : #colorLiteral(red: 0.9254901961, green: 0.7450980392, blue: 0.4784313725, alpha: 1)
        let image = model.isChecked ? #imageLiteral(resourceName: "filledCircle") : #imageLiteral(resourceName: "unfilledCircle")
        checkedButton.setImage(image, for: .normal)
        reminderLabel.text = model.reminder
        if let location = model.locationLabel {
            locationLabel.text = location
        } else {
            locationLabel.text = nil
        }
    }
    
    private func isEven(_ int: Int) -> Bool {
        if int == 0 {
            return true
        }
        if int % 2 == 0 {
            return true
        }
        return false
    }
}
