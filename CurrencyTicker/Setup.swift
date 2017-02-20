//
//  Setup.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 20.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import CurrencyTickerKit

class Setup {
    init() {
        self.setupFavouriteCurrency()
    }
    
    func setupFavouriteCurrency() {
        if !FavouriteCurrency.shared.isDefined() {
            if let currencyCode = Locale.current.currencyCode {
                YahooFinanceAPI.shared
                    .currencyList()
                    .map { $0.currencies.filter { $0.symbol?.code == currencyCode } }
                    .on(value: { (currencies: [YahooCurrency]) in
                        if currencies.count == 0 {
                            FavouriteCurrency.shared.set(currency: [YahooCurrency.currency(currencyCode: currencyCode)])
                        }
                        else {
                            FavouriteCurrency.shared.set(currency: currencies)
                        }
                    })
                    .start()
            }
        }
    }
}
