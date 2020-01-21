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
    
    var bitcoinList: [(String, Double)] = []
    
    @IBOutlet weak var ui_startDate: UITextField!
    @IBOutlet weak var ui_endDate: UITextField!
    @IBOutlet weak var ui_currency: UITextField!
    @IBOutlet weak var ui_tableView: UITableView!
    
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
        
        ui_tableView.dataSource = self
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
            AF.request(url, method: .get).responseDecodable { [weak self] (response: DataResponse<Bitcoin, AFError>) in
                switch response.result {
                case .success(let bitcoin):
                    if let bpi = bitcoin.bpi {
                        let sortedBpi = bpi.sorted(by: {
                            ViewController.dateFormatter.date(from: $0.key)! <  ViewController.dateFormatter.date(from: $1.key)!
                        })
                                                
                        self?.bitcoinList = sortedBpi
                        self?.ui_tableView.reloadData()
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

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bitcoinList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dynamicCell = tableView.dequeueReusableCell(withIdentifier: "bitcoinCellID", for: indexPath) as? BitcoinTableViewCell {
            
            let (date, price) = bitcoinList[indexPath.row]
            dynamicCell.fill(withDate: date, andPrice: price)
            return dynamicCell
        } else {
            return UITableViewCell()
        }
    }
}
