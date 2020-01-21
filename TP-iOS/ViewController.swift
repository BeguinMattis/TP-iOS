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
    private static let currentDate = Date()
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
        if let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: ViewController.currentDate) {
            ui_startDate.inputView = generateStartDateDatePicker(date: yesterdayDate, endDate: ViewController.currentDate)
            ui_startDate.text = ViewController.dateFormatter.string(from: yesterdayDate)
            ui_endDate.inputView = generateEndDateDatePicker(date: ViewController.currentDate, startDate: yesterdayDate)
            ui_endDate.text = ViewController.dateFormatter.string(from: ViewController.currentDate)
        }
        
        ui_tableView.dataSource = self
    }
    
    private func generateDatePicker(date: Date) -> UIDatePicker {
        let uIDatePicker = UIDatePicker()
        uIDatePicker.datePickerMode = UIDatePicker.Mode.date
        uIDatePicker.setDate(date, animated: true)
        
        return uIDatePicker
    }
    
    private func generateStartDateDatePicker(date: Date, endDate: Date) -> UIDatePicker {
        let uIDatePicker = generateDatePicker(date: date)
        uIDatePicker.maximumDate = endDate
        uIDatePicker.addTarget(self, action: #selector(startDateValueChanged(sender:)), for: .valueChanged)
        
        return uIDatePicker
    }
    
    @objc private func startDateValueChanged(sender: UIDatePicker) {
        if let endDateString = ui_endDate.text, let endDateDate = ViewController.dateFormatter.date(from: endDateString), sender.date <= endDateDate {
            ui_endDate.inputView = generateEndDateDatePicker(date: endDateDate, startDate: sender.date)
            ui_startDate.inputView = generateStartDateDatePicker(date: sender.date, endDate: endDateDate)
            ui_startDate.text = ViewController.dateFormatter.string(from: sender.date)
        }
    }
    
    private func generateEndDateDatePicker(date: Date, startDate: Date) -> UIDatePicker {
        let uIDatePicker = generateDatePicker(date: date)
        uIDatePicker.minimumDate = startDate
        uIDatePicker.maximumDate = ViewController.currentDate
        uIDatePicker.addTarget(self, action: #selector(endDateValueChanged(sender:)), for: .valueChanged)
        
        return uIDatePicker
    }
    
    @objc private func endDateValueChanged(sender: UIDatePicker) {
        if let startDateString = ui_startDate.text, let startDateDate = ViewController.dateFormatter.date(from: startDateString), sender.date >= startDateDate && sender.date <= ViewController.currentDate {
            ui_startDate.inputView = generateStartDateDatePicker(date: startDateDate, endDate: sender.date)
            ui_endDate.inputView = generateEndDateDatePicker(date: sender.date, startDate: startDateDate)
            ui_endDate.text = ViewController.dateFormatter.string(from: sender.date)
        }
    }

    @IBAction func searchAction(_ sender: Any) {
        if let selectedStartDate = ui_startDate.text, let selectedEndDate = ui_endDate.text, let selectedCurrency = ui_currency.text {
            let url = "https://api.coindesk.com/v1/bpi/historical/close.json?start=\(selectedStartDate)&end=\(selectedEndDate)&currency=\(selectedCurrency)"
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
