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
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    @IBOutlet weak var ui_startDate: UITextField!
    @IBOutlet weak var ui_endDate: UITextField!
    @IBOutlet weak var ui_currency: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        var uIDatePicker = UIDatePicker()
        uIDatePicker.datePickerMode = UIDatePicker.Mode.date
        uIDatePicker.addTarget(self, action: #selector(startDateValueChanged(sender:)), for: .valueChanged)
        ui_startDate.inputView = uIDatePicker
               
        uIDatePicker = UIDatePicker()
        uIDatePicker.datePickerMode = UIDatePicker.Mode.date
        uIDatePicker.addTarget(self, action: #selector(endDateValueChanged(sender:)), for: .valueChanged)
        ui_endDate.inputView = uIDatePicker
        
        let date = Date()
        ui_startDate.text = ViewController.dateFormatter.string(from: date)
        ui_endDate.text = ViewController.dateFormatter.string(from: date)
    }
    
    @objc func startDateValueChanged(sender: UIDatePicker) {
        ui_startDate.text = ViewController.dateFormatter.string(from: sender.date)
    }
    
    @objc func endDateValueChanged(sender: UIDatePicker) {
        ui_endDate.text = ViewController.dateFormatter.string(from: sender.date)
    }

    @IBAction func searchAction(_ sender: Any) {
        if let selectedStartDate = ui_startDate.text, let selectedEndDate = ui_endDate.text, let selectedCurrency = ui_currency.text {
            let url = "https://api.coindesk.com/v1/bpi/historical/\(selectedCurrency).json?start=\(selectedStartDate)&end=\(selectedEndDate)"
            AF.request(url, method: .get).responseDecodable { (response: DataResponse<Bitcoin, AFError>) in
                switch response.result {
                case .success(let bitcoin):
                    if let bpi = bitcoin.bpi {
                        let sortedBpi = bpi.sorted(by: {
                            ViewController.dateFormatter.date(from: $0.key)! <  ViewController.dateFormatter.date(from: $1.key)!
                        })

                        for (date, price) in sortedBpi {
                            print("\(date): \(price)")
                        }
                    }
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
            }
        } else {
            print("Erreur")
        }
    }
}
