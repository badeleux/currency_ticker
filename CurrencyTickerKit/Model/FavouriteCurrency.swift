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
    
    public func remove(currency: CurrencyCode) {
        var currencies = self.get()
        let index = currencies.index(of: currency)
        if let i = index {
            currencies.remove(at: i)
            self.userDefaults.set(currencies, forKey: FavouriteCurrency.FavCurrenciesKey)
            self.userDefaults.synchronize()
        }
    }
    
    public func get() -> [CurrencyCode] {
        if let o = self.userDefaults.object(forKey: FavouriteCurrency.FavCurrenciesKey) as? [CurrencyCode] {
            return o
        }
        return []
    }
    
    public lazy var stream: Signal<[CurrencyCode], NoError> = {
        return NotificationCenter.default
            .reactive
            .notifications(forName: UserDefaults.didChangeNotification, object: self.userDefaults)
            .map { [weak self] _ in self?.get() ?? [] }
    }()
    
    public func add(currency: CurrencyCode) {
        self.set(currencies: self.get() + [currency])
    }
    
    public func isDefined() -> Bool {
        return self.userDefaults.array(forKey: FavouriteCurrency.FavCurrenciesKey) != nil
    }
}
