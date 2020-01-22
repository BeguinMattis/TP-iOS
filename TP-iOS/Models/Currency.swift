//
//  Currency.swift
//  TP-iOS
//
//  Created by Thibault VASSEUR on 21/01/2020.
//  Copyright © 2020 Mattis Beguin. All rights reserved.
//

import Foundation

class Currency: Codable {
    var currency: String?
    var country: String?

    init(currency: String?, country: String?) {
        self.currency = currency
        self.country = country
    }
}
