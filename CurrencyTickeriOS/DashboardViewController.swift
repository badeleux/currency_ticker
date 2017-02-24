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
import Result
import Moya
import DZNEmptyDataSet
import SwiftDate

class DashboardViewController: UITableViewController {
    static let CurrencyCellReuseIdentifier = "CurrencyCell"
    
    let viewModel = CurrecyExchangeRatesViewModel()
    let rates = MutableProperty<[YahooCurrencyExchanceRate]>([])
    let emptyState = EmptyStateDataSource(screen: .dashboard)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //table view customisation
        self.tableView.tableFooterView = UIView()

        //empty state setup
        self.viewModel.loading
            .observeValues({ [weak self] (isLoading: Bool) in
                if !isLoading {
                    self?.refreshControl?.endRefreshing()
                }
            })
        
        let state = self.viewModel.emptyListState()
        self.emptyState.state <~ state
        self.tableView.emptyDataSetSource = self.emptyState
        self.tableView.emptyDataSetDelegate = self
        
        //data setup
        FavouriteCurrency.shared.stream.observeValues { [weak self] (currencies: [CurrencyCode]) in
            self?.viewModel.configureWith(codes: currencies)
        }
        self.rates <~ viewModel.rates.map { $0?.rates ?? [] }
        
        
        //updating table
        let updateTableView: Signal<(), NoError> = .merge(self.rates.signal.map { _ in () }, state.map { _ in () })
        updateTableView.observeValues { [weak self ] _ in self?.tableView.reloadData() }
        
        //refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DashboardViewController.refreshList), for: .valueChanged)
        self.refreshControl = refreshControl
        
        //on view did load refresh list
        self.refreshList()
    }
    
    func refreshList() {
        self.viewModel.configureWith(codes: FavouriteCurrency.shared.get())
    }
 
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currencyCode = FavouriteCurrency.shared.get()[indexPath.row]
        let viewModel = self.viewModel.yahooChartViewModel()
        viewModel.configureWith(currencyCode: currencyCode)
        viewModel.timePeriod(last: 1.month)
        self.navigationController?.pushViewController(CandleStickInteractiveChartViewController(chartViewModel: viewModel), animated: true)
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
        cell.rateLabel.text = rate.rate?.description ?? "-"
    }
}

extension DashboardViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
