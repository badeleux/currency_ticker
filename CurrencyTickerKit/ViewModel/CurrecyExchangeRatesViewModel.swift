//
//  CurrecyExchangeRatesViewModel.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 22.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Moya

protocol CurrencyExchangeRatesViewModelInputs {
    func configureWith(codes: [CurrencyCode])
}

protocol CurrencyExchangeRatesViewModelOutputs {
    var rates: Signal<AnyYahooCurrenciesExchangeQueryResult?, NoError> { get }
}

struct CurrecyExchangeRatesViewModel: CurrencyExchangeRatesViewModelInputs, CurrencyExchangeRatesViewModelOutputs {
    let currencyCodes = MutableProperty<[CurrencyCode]>([])
    let ratesQueryResult = MutableProperty<AnyYahooCurrenciesExchangeQueryResult?>(nil)
    
    init() {
        let result = currencyCodes.signal.flatMap(.latest, transform: { (codes: [CurrencyCode]) -> SignalProducer<AnyYahooCurrenciesExchangeQueryResult?, NoError> in
            return YahooFinanceAPI.shared.currenciesExchange(pairs: codes.flatMap { self.toPair(code: $0) }).map { Optional($0) }.ignoreError()
        })
        ratesQueryResult <~ result
    }
    
    func toPair(code: CurrencyCode) -> YahooCurrencyPairable {
        return YahooUSDCurrencyPair(to: code)
    }
    
    // MARK: - Inputs
    
    func configureWith(codes: [CurrencyCode]) {
        
    }
    
    // MARK: - Outputs
    
    var rates: Signal<AnyYahooCurrenciesExchangeQueryResult?, NoError> {
        return self.ratesQueryResult.signal
    }
}

