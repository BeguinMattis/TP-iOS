//
//  Bitcoin.swift
//  TP-iOS
//
//  Created by Mattis Beguin on 21/01/2020.
//  Copyright © 2020 Mattis Beguin. All rights reserved.
//

import Foundation

class Bitcoin: Codable {
    var bpi: [String: Double]?

    init(bpi: [String: Double]?) {
        self.bpi = bpi
    }
}
