//
//  YahooFinance.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 17.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation

struct YahooCurrencySymbol: APIStringRepresentable {
    let currency: Currency
    
    func apiStringRepresentation() -> String {
        return self.currency + "=X"
    }
}

struct YahooCurrencyPair: APIStringRepresentable {
    let from: Currency
    let to: Currency
    
    func apiStringRepresentation() -> String {
        return from + to
    }
}
