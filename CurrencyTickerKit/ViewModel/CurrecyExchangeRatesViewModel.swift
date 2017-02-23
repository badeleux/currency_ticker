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

public protocol CurrencyExchangeRatesViewModelInputs {
    func configureWith(codes: [CurrencyCode])
}

public protocol CurrencyExchangeRatesViewModelOutputs {
    var rates: Signal<AnyYahooCurrenciesExchangeQueryResult?, NoError> { get }
}

public class CurrecyExchangeRatesViewModel: LoadableViewModel, CurrencyExchangeRatesViewModelInputs, CurrencyExchangeRatesViewModelOutputs {
    let currencyCodes = MutableProperty<[CurrencyCode]>([])
    let ratesQueryResult = MutableProperty<AnyYahooCurrenciesExchangeQueryResult?>(nil)
    
    public let error: Signal<MoyaError, NoError>
    public let loading: Signal<Bool, NoError>
    
    private let errorProperty = MutableProperty<MoyaError?>(nil)
    private let loadingProperty = MutableProperty<Bool>(false)
    
    public init() {
        self.error = errorProperty.signal.skipNil()
        self.loading = loadingProperty.signal
        
        let result = self.currencyCodes.signal.flatMap(.latest, transform: { (codes: [CurrencyCode]) -> SignalProducer<AnyYahooCurrenciesExchangeQueryResult?, NoError> in
            let api = YahooFinanceAPI.shared
                .currenciesExchange(pairs: codes.flatMap { self.toPair(code: $0) })
                .map { Optional($0) }
            return api
                .forwardError(property: self.errorProperty)
                .forwardLoading(property: self.loadingProperty)
                .ignoreError()
        })
        ratesQueryResult <~ result
        
    }
    
    func toPair(code: CurrencyCode) -> YahooCurrencyPairable {
        if code == YahooConstants.USD {
            return YahooEURCurrencyPair(to: code)
        }
        else {
            return YahooUSDCurrencyPair(to: code)
        }
    }
    
    // MARK: - Inputs
    
    public func configureWith(codes: [CurrencyCode]) {
        self.currencyCodes.value = codes
    }
    
    // MARK: - Outputs
    
    public var rates: Signal<AnyYahooCurrenciesExchangeQueryResult?, NoError> {
        return self.ratesQueryResult.signal
    }
    
    var inputs: CurrencyExchangeRatesViewModelInputs { return self }
    
    var outputs: CurrencyExchangeRatesViewModelOutputs { return self }
    
}

