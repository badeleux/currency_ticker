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
                FavouriteCurrency.shared.set(currencies: [currencyCode])
            }
        }
    }
}
