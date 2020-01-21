//
//  ViewController.swift
//  TP-iOS
//
//  Created by Mattis Beguin on 21/01/2020.
//  Copyright © 2020 Mattis Beguin. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var ui_startDate: UIDatePicker!
    @IBOutlet weak var ui_endDate: UIDatePicker!
    @IBOutlet weak var ui_currency: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func searchAction(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedStartDate = dateFormatter.string(from: ui_startDate.date)
        let selectedEndDate = dateFormatter.string(from: ui_endDate.date)
        let selectedCurrency = ui_currency.text ?? "EUR"
        let url = "https://api.coindesk.com/v1/bpi/historical/\(selectedCurrency).json?start=\(selectedStartDate)&end=\(selectedEndDate)"
        print("URL : \(url)")
        AF.request(url, method: .get).responseDecodable { (response: DataResponse<Bitcoin, AFError>) in
            switch response.result {
            case .success(let bitcoin):
                if let bpi = bitcoin.bpi {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let sortedBpi = bpi.sorted(by: {
                        dateFormatter.date(from: $0.key)! < dateFormatter.date(from: $1.key)!
                    })

                    for (date, price) in sortedBpi {
                        print("\(date): \(price)")
                    }
                }
            case .failure(let error):
                print(error.errorDescription ?? "")
            }
        }
    }
}
