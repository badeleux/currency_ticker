//
//  DashboardViewController.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 21.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import UIKit
import CurrencyTickerKit
import ReactiveSwift

class DashboardViewController: UITableViewController {
    static let CurrencyCellReuseIdentifier = "CurrencyCell"
    
    let viewModel = CurrecyExchangeRatesViewModel()
    let rates = MutableProperty<[YahooCurrencyExchanceRate]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.configureWith(codes: FavouriteCurrency.shared.get())
        FavouriteCurrency.shared.stream.observeValues { [weak self] (currencies: [CurrencyCode]) in
            self?.viewModel.configureWith(codes: currencies)
        }
        self.rates <~ viewModel.rates.map { $0?.rates ?? [] }
        self.rates.signal.observeValues { [weak self] (rates: [YahooCurrencyExchanceRate]) in
            self?.tableView.reloadData()
        }
    }
 
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rates.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DashboardViewController.CurrencyCellReuseIdentifier, for: indexPath) as! CurrencyTableViewCell
        configureCell(cell: cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: CurrencyTableViewCell, forRowAtIndexPath ip: IndexPath) {
        let rate = self.rates.value[ip.row]
        cell.currencyCodeLabel.text = rate.name.name
        cell.rateLabel.text = rate.rate.description
    }
}
