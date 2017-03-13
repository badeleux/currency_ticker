//
//  CurrencyChart.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import CurrencyTickerKit

protocol UIViewControllerProtocol { }
extension UIViewControllerProtocol {
    var viewController: UIViewController {
        return self as! UIViewController
    }
}
extension UIViewController: UIViewControllerProtocol { }

protocol CurrencyChartViewController: UIViewControllerProtocol {
    associatedtype VM: CurrencyHistoricalDataViewModelOutputs
    init(viewModel: VM)
}
