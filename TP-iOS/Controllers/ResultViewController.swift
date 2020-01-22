//
//  ResultViewController.swift
//  TP-iOS
//
//  Created by Mattis Beguin on 21/01/2020.
//  Copyright © 2020 Mattis Beguin. All rights reserved.
//

import UIKit
import Alamofire
import Charts

class ResultViewController: UIViewController {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    var startDate: String?
    var endDate: String?
    var currency: String?
    var bitcoinList: [(String, Double)] = []

    @IBOutlet weak var ui_table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ui_table.dataSource = self
        search()
    }
    
    func search() {
        if let selectedStartDate = startDate, let selectedEndDate = endDate, let selectedCurrency = currency {
               let url = "https://api.coindesk.com/v1/bpi/historical/close.json?start=\(selectedStartDate)&end=\(selectedEndDate)&currency=\(selectedCurrency)"
               AF.request(url, method: .get).responseDecodable { [weak self] (response: DataResponse<Bitcoin, AFError>) in
                   switch response.result {
                   case .success(let bitcoin):
                       if let bpi = bitcoin.bpi {
                           let sortedBpi = bpi.sorted(by: {ResultViewController.dateFormatter.date(from: $0.key)! < ResultViewController.dateFormatter.date(from: $1.key)!
                           })
                                                   
                           self?.bitcoinList = sortedBpi
                           self?.ui_table.reloadData()
                       }
                   case .failure(let error):
                       print(error.errorDescription ?? "")
                   }
               }
           } else {
               print("Error")
           }
       }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ResultViewController: UITableViewDataSource {
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
