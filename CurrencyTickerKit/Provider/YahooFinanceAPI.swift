//
//  YahooFinanceAPI.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 18.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import Moya_Argo

import Moya
import ReactiveSwift
import Argo


public class YahooFinanceAPI {
    let provider = ReactiveSwiftMoyaProvider<YahooFinanceRouter>(plugins: [NetworkLoggerPlugin()])
    public static let shared = YahooFinanceAPI()
    private init() { }
    
    public func currencyList() -> SignalProducer<YahooCurrencyList, MoyaError> {
        return self.provider
            .request(.currencyList)
            .mapObject(type: YahooCurrencyList.self, rootKey: "list")
    }
    
    public func currencyExchange(pair: YahooCurrencyPairable) -> SignalProducer<AnyYahooCurrenciesExchangeQueryResult, MoyaError> {
        return self.provider
            .request(.exchangeRate(pairs: [pair]))
            .mapObject(type: YahooCurrencyExchangeQueryResult.self, rootKey: "query")
            .map { AnyYahooCurrenciesExchangeQueryResult(results: $0) }
    }
    
    public func currenciesExchange(pairs: [YahooCurrencyPairable]) -> SignalProducer<AnyYahooCurrenciesExchangeQueryResult, MoyaError> {
        if pairs.count == 1 {
            return self.currencyExchange(pair: pairs.first!)
        }
        else {
            return self.provider
                .request(.exchangeRate(pairs: pairs))
                .mapObject(type: YahooCurrenciesExchangeQueryResult.self, rootKey: "query")
                .map { AnyYahooCurrenciesExchangeQueryResult(results: $0) }
        }
    }
    
    public func currencyHistoricalData(symbol: YahooCurrencySymbol, start: Date, end: Date) -> SignalProducer<YahooSymbolHistoricalDataQueryResult, MoyaError> {
        return self.provider
            .request(.historicalData(symbol: symbol, dateStart: start, dateEnd: end))
            .mapObject(type: YahooSymbolHistoricalDataQueryResult.self, rootKey: "query")
    }
    
}
