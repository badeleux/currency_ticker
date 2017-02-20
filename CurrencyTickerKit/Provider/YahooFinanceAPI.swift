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


class YahooFinanceAPI {
    let provider = ReactiveSwiftMoyaProvider<YahooFinanceRouter>(plugins: [NetworkLoggerPlugin()])
    
    func currencyList() -> SignalProducer<YahooCurrencyList, MoyaError> {
        return self.provider
            .request(.currencyList)
            .mapObject(type: YahooCurrencyList.self, rootKey: "list")
    }
    
    func currencyExchange(pair: YahooCurrencyPairable) -> SignalProducer<YahooCurrencyExchangeQueryResult, MoyaError> {
        return self.provider
            .request(.exchangeRate(pair: pair))
            .mapObject(type: YahooCurrencyExchangeQueryResult.self, rootKey: "query")
    }
    
    func currencyHistoricalData(symbol: YahooCurrencySymbol, start: Date, end: Date) -> SignalProducer<YahooSymbolHistoricalDataQueryResult, MoyaError> {
        return self.provider
            .request(.historicalData(symbol: symbol, dateStart: start, dateEnd: end))
            .mapObject(type: YahooSymbolHistoricalDataQueryResult.self, rootKey: "query")
    }
    
}
