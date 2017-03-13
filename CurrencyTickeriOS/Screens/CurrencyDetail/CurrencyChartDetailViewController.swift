//
//  CurrencyChartDetailViewController.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import CurrencyTickerKit
import EasyPeasy

enum DefinedTimePeriod {
    case lastWeek, lastMonth, lastThreeMonths, lastSixMonths
    
    func localizedDescription() -> String {
        switch self {
        case .lastWeek:
            return NSLocalizedString("chart_time_period_last_week", comment: "")
        case .lastMonth:
            return NSLocalizedString("chart_time_period_last_month", comment: "")
        case .lastThreeMonths:
            return NSLocalizedString("chart_time_period_last_three_months", comment: "")
        case .lastSixMonths:
            return NSLocalizedString("chart_time_period_last_six_months", comment: "")
        }
    }
    
    static func all() -> [DefinedTimePeriod] {
        return [.lastWeek, .lastMonth, .lastThreeMonths, .lastSixMonths]
    }
    
    func timePeriod() -> DateComponents {
        switch self {
        case .lastWeek:
            return 1.week
        case .lastMonth:
            return 1.month
        case .lastThreeMonths:
            return 3.months
        case .lastSixMonths:
            return 6.months
        }
    }
}

class CurrencyChartDetailViewController<VM: CurrencyHistoricalDataViewModelInputs & CurrencyHistoricalDataViewModelOutputs, VC: CurrencyChartViewController>: UIViewController
    where VC.VM == VM, VC.VM.T == VM.T {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var chartContainerView: UIView!
    let viewModel: VM
    let chartViewController: VC
    
    init(currencyCode: CurrencyCode, viewModel: VM, chartType: VC.Type) {
        self.viewModel = viewModel
        self.chartViewController = chartType.init(viewModel: viewModel)
        super.init(nibName: "CurrencyChartDetailViewController", bundle: Bundle.iosFramework)
        self.title = currencyCode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //chart
        self.addChildViewController(self.chartViewController.viewController)
        self.chartContainerView.addSubview(self.chartViewController.viewController.view)
        self.chartViewController.viewController.view <- Edges(0)
        
        self.segmentedControl.removeAllSegments()
        //segmented control
        DefinedTimePeriod.all()
            .enumerated()
            .forEach { index, period in self.segmentedControl.insertSegment(withTitle: period.localizedDescription(), at: index, animated: false) }
        
        //viewmodel
        self.segmentedControl.reactive.selectedSegmentIndexes
            .map { DefinedTimePeriod.all()[$0] }
            .observeValues { (period: DefinedTimePeriod) in
                self.viewModel.timePeriod(last: period.timePeriod())
            }
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.sendActions(for: .valueChanged)
        
    }
}
