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
    
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var selectedCurrency: Currency?
    var currencyList: [Currency] = []
    
    @IBOutlet weak var ui_startDate: UITextField!
    @IBOutlet weak var ui_endDate: UITextField!
    @IBOutlet weak var ui_currency: UITextField!
    
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
        
        fetchAllCurrencies()
        generateCurrencyPicker()
    }
    
    private func generateDatePicker(date: Date) -> UIDatePicker {
        let uIDatePicker = UIDatePicker()
        uIDatePicker.datePickerMode = UIDatePicker.Mode.date
        uIDatePicker.setDate(date, animated: false)
        uIDatePicker.backgroundColor = UIColor.white
        
        return uIDatePicker
    }
    
    private func generateStartDateDatePicker(date: Date, endDate: Date) -> UIDatePicker {
        let uIDatePicker = generateDatePicker(date: date)
        uIDatePicker.maximumDate = endDate
        uIDatePicker.addTarget(self, action: #selector(startDateValueChanged(sender:)), for: .valueChanged)
        
        let doneButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(startDateDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Annuler", style: .plain, target: self, action: #selector(startDateCancelClick))
        
        let uiToolBar = UIToolbar()
        uiToolBar.barStyle = .default
        uiToolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        uiToolBar.sizeToFit()
        uiToolBar.isUserInteractionEnabled = true
        ui_startDate.inputAccessoryView = uiToolBar
        
        return uIDatePicker
    }
    
    @objc private func startDateDoneClick() {
        if let startDateDate = selectedStartDate, let endDateString = ui_endDate.text, let endDateDate = ViewController.dateFormatter.date(from: endDateString), startDateDate <= endDateDate {
            ui_startDate.text = ViewController.dateFormatter.string(from: startDateDate)
            ui_startDate.inputView = generateStartDateDatePicker(date: startDateDate, endDate: endDateDate)
            ui_endDate.inputView = generateEndDateDatePicker(date: endDateDate, startDate: startDateDate)
        }
        
         ui_startDate.resignFirstResponder()
    }
    
    @objc private func startDateCancelClick() {
        if let startDateString = ui_startDate.text, let startDateDate = ViewController.dateFormatter.date(from: startDateString), let endDateString = ui_endDate.text, let endDateDate = ViewController.dateFormatter.date(from: endDateString), startDateDate <= endDateDate {
            selectedStartDate = startDateDate
            ui_startDate.inputView = generateStartDateDatePicker(date: startDateDate, endDate: endDateDate)
            ui_endDate.inputView = generateEndDateDatePicker(date: endDateDate, startDate: startDateDate)
        }
        
        ui_startDate.resignFirstResponder()
    }
    
    @objc private func startDateValueChanged(sender: UIDatePicker) {
        selectedStartDate = sender.date
    }
    
    private func generateEndDateDatePicker(date: Date, startDate: Date) -> UIDatePicker {
        let uIDatePicker = generateDatePicker(date: date)
        uIDatePicker.minimumDate = startDate
        uIDatePicker.maximumDate = ViewController.currentDate
        uIDatePicker.addTarget(self, action: #selector(endDateValueChanged(sender:)), for: .valueChanged)
        
        let doneButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(endDateDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Annuler", style: .plain, target: self, action: #selector(endDateCancelClick))
        
        let uiToolBar = UIToolbar()
        uiToolBar.barStyle = .default
        uiToolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        uiToolBar.sizeToFit()
        uiToolBar.isUserInteractionEnabled = true
        ui_endDate.inputAccessoryView = uiToolBar
        
        return uIDatePicker
    }
    
    @objc private func endDateDoneClick() {
        if let endDateDate = selectedEndDate, let startDateString = ui_startDate.text, let startDateDate = ViewController.dateFormatter.date(from: startDateString), startDateDate <= endDateDate {
            ui_endDate.text = ViewController.dateFormatter.string(from: endDateDate)
            ui_startDate.inputView = generateStartDateDatePicker(date: startDateDate, endDate: endDateDate)
            ui_endDate.inputView = generateEndDateDatePicker(date: endDateDate, startDate: startDateDate)
        }
        
         ui_endDate.resignFirstResponder()
    }
       
    @objc private func endDateCancelClick() {
        if let startDateString = ui_startDate.text, let startDateDate = ViewController.dateFormatter.date(from: startDateString), let endDateString = ui_endDate.text, let endDateDate = ViewController.dateFormatter.date(from: endDateString), startDateDate <= endDateDate {
            selectedEndDate = endDateDate
            ui_startDate.inputView = generateStartDateDatePicker(date: startDateDate, endDate: endDateDate)
            ui_endDate.inputView = generateEndDateDatePicker(date: endDateDate, startDate: startDateDate)
        }
        
        ui_endDate.resignFirstResponder()
    }
    
    @objc private func endDateValueChanged(sender: UIDatePicker) {
        selectedEndDate = sender.date
    }
    
    func fetchAllCurrencies() {
        ui_currency.isUserInteractionEnabled = false
        let url = "https://api.coindesk.com/v1/bpi/supported-currencies.json"
        AF.request(url, method: .get).responseDecodable { [weak self] (response: DataResponse<[Currency], AFError>) in
            switch response.result {
            case .success(let currencies):
                self?.currencyList.append(contentsOf: currencies)
                self?.ui_currency.isUserInteractionEnabled = true
            case .failure(let error):
                print(error.errorDescription ?? "")
            }
        }
    }
    
    private func generateCurrencyPicker() {
        let uIPickerView = UIPickerView()
        uIPickerView.delegate = self
        uIPickerView.dataSource = self
        uIPickerView.backgroundColor = UIColor.white
        
        if let currency = selectedCurrency, let index = currencyList.firstIndex(where: {$0 === currency}) {
             uIPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        ui_currency.inputView = uIPickerView
        
        let doneButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(currencyDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Annuler", style: .plain, target: self, action: #selector(currencyCancelClick))
        
        let uiToolBar = UIToolbar()
        uiToolBar.barStyle = .default
        uiToolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        uiToolBar.sizeToFit()
        uiToolBar.isUserInteractionEnabled = true
        ui_currency.inputAccessoryView = uiToolBar
    }
    
    @objc private func currencyDoneClick() {
        ui_currency.text = selectedCurrency?.country
        generateCurrencyPicker()
        ui_currency.resignFirstResponder()
    }
    
    @objc private func currencyCancelClick() {
        if let currency = currencyList.first(where: {$0.country == ui_currency.text}) {
            selectedCurrency = currency
            generateCurrencyPicker()
        }
        
        ui_currency.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-result" {
            if let startDate = ui_startDate.text, let endDate = ui_endDate.text, let currency = selectedCurrency?.currency, let resultViewController: ResultViewController = segue.destination as? ResultViewController {
                resultViewController.startDate = startDate
                resultViewController.endDate = endDate
                resultViewController.currency = currency
            }
        }
    }
    
    @IBAction func returnHome(_ segue: UIStoryboardSegue) {}
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyList[row].country
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = currencyList[row]
    }
}
