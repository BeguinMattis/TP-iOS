//
//  BitcoinTableViewCell.swift
//  TP-iOS
//
//  Created by Thibault VASSEUR on 21/01/2020.
//  Copyright © 2020 Mattis Beguin. All rights reserved.
//

import UIKit

class BitcoinTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_dateLabel: UILabel!
    @IBOutlet weak var ui_priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fill(withDate date: String, andPrice price: Double) {
        ui_dateLabel.text = date
        ui_priceLabel.text = "\(price)€"
    }

}
