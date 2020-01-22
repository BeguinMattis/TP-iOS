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
    
    var currenciesValues: [Double] = []
    var currenciesDates: [String] = []
    var selectedCell: UITableViewCell?

    @IBOutlet weak var ui_table: UITableView!
    @IBOutlet weak var ui_chart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ui_table.dataSource = self
        ui_table.delegate = self
        ui_chart.delegate = self
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
                               
                        // Table
                        self?.bitcoinList = sortedBpi
                        self?.ui_table.reloadData()
                    
                        // Chart
                        self?.chartDatas()
                        self?.plotDatas()
                   }
               case .failure(let error):
                   print(error.errorDescription ?? "")
               }
           }
       } else {
           print("Error")
       }
    }
    
    func chartDatas() {
        currenciesValues.removeAll()
        currenciesDates.removeAll()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        
        for (date, price) in bitcoinList {
            currenciesValues.append(price)
            currenciesDates.append(date)
        }
    }
    
    func plotDatas() {
        var values = [ChartDataEntry]()
        
        for i in 0 ..< currenciesValues.count {
            values.append(ChartDataEntry(x: Double(i), y: currenciesValues[i]))
        }
        
        let gradiant = getGradiant()
        let data = LineChartData()
        let ds = LineChartDataSet(entries: values, label: "Bitcoin value")
                
        data.setDrawValues(false)
        ds.colors = [UIColor.systemBlue]
        ds.drawValuesEnabled = false
        ds.drawCirclesEnabled = false
        ds.drawFilledEnabled = true
        ds.fill = Fill.fillWithLinearGradient(gradiant, angle: 90)
        ds.mode = .cubicBezier
                
        // Basics
        ui_chart.backgroundColor = UIColor.clear
        ui_chart.chartDescription?.enabled = false
        ui_chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        ui_chart.drawBordersEnabled = false
        ui_chart.legend.enabled = false
        
        // XAxis
        ui_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: currenciesDates)
        ui_chart.xAxis.granularity = 1
        ui_chart.xAxis.labelPosition = .bottom
        ui_chart.xAxis.drawLabelsEnabled = currenciesValues.count < 7
        ui_chart.xAxis.drawAxisLineEnabled = false
        ui_chart.xAxis.drawGridLinesEnabled = false
        
        // RightAxis
        ui_chart.rightAxis.enabled = false
        
        // LeftAxis
        ui_chart.leftAxis.drawAxisLineEnabled = false
        ui_chart.leftAxis.drawGridLinesEnabled = false
    
        data.addDataSet(ds)
        ui_chart.data = data
        ui_chart.notifyDataSetChanged()
        
    }
    
    func getGradiant() -> CGGradient {
        let colors = [UIColor.systemBlue.withAlphaComponent(0.5).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor] as CFArray
        let locations = [0.7, 0.0] as [CGFloat]
        let gradiant = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations)
        
        return gradiant!
    }
}

extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        // TODO: Highlight in chart
    }
}

extension ResultViewController: ChartViewDelegate {
    override func viewWillAppear(_ animated: Bool) {
        self.chartDatas()
        self.plotDatas()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let index = ui_chart.data?.dataSets[highlight.dataSetIndex].entryIndex(entry: entry) {
            selectedCell?.backgroundColor = UIColor.clear
            let indexPath = IndexPath(row: index, section: 0)
            selectedCell = ui_table.cellForRow(at: indexPath)
            ui_table.scrollToRow(at: indexPath, at: .middle, animated: false)
            selectedCell?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        }
    }
}
