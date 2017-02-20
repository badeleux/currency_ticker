//
//  FavouriteCurrency.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 20.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Argo

class FavouriteCurrency {
    static let FavCurrenciesKey = "FavCurrenciesKey"
    public static let shared = FavouriteCurrency()
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    public func set(currency: [YahooCurrency]) {
        self.userDefaults.set(currency.encode().JSONObject(), forKey: FavouriteCurrency.FavCurrenciesKey)
        self.userDefaults.synchronize()
    }
    
    public func get() -> [YahooCurrency] {
        if let o = self.userDefaults.object(forKey: FavouriteCurrency.FavCurrenciesKey) {
            let currencies: [YahooCurrency]? = decode(o)
            return currencies ?? []
        }
        return []
    }
    
    public func add(currency: YahooCurrency) {
        self.set(currency: self.get() + [currency])
    }
    
    public func isDefined() -> Bool {
        return self.userDefaults.array(forKey: FavouriteCurrency.FavCurrenciesKey) != nil
    }
}
