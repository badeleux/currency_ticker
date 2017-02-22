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

public class FavouriteCurrency {
    static let FavCurrenciesKey = "FavCurrenciesKey"
    public static let shared = FavouriteCurrency()
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    public func set(currencies: [CurrencyCode]) {
        self.userDefaults.set(currencies, forKey: FavouriteCurrency.FavCurrenciesKey)
        self.userDefaults.synchronize()
    }
    
    public func get() -> [CurrencyCode] {
        if let o = self.userDefaults.object(forKey: FavouriteCurrency.FavCurrenciesKey) as? [CurrencyCode] {
            return o
        }
        return []
    }
    
    public func add(currency: CurrencyCode) {
        self.set(currencies: self.get() + [currency])
    }
    
    public func isDefined() -> Bool {
        return self.userDefaults.array(forKey: FavouriteCurrency.FavCurrenciesKey) != nil
    }
}
