//
//  Formatters.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation

class DefaultDateFormatter {
    static let shared = DefaultDateFormatter()
    private init() {}
    
    lazy var short: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
    lazy var chartAxis: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        return dateFormatter
    }()
}
