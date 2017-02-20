//
//  YahooFinanceContainers.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 18.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

public struct YahooCurrencyList {
    public let currencies: [YahooCurrency]
}

extension YahooCurrencyList: Decodable {
    public static func decode(_ json: JSON) -> Decoded<YahooCurrencyList> {
        return curry(YahooCurrencyList.init)
            <^> json <|| "resources"
    }
    
    public static func mockedJSON() -> Data? {
        return try? Data(contentsOf: Bundle.kit.url(forResource: "currency_list", withExtension: "json")!)
    }
}

public struct YahooCurrencyExchangeQueryResult {
    public let rate: YahooCurrencyExchanceRate
}

extension YahooCurrencyExchangeQueryResult: Decodable {
    public static func decode(_ json: JSON) -> Decoded<YahooCurrencyExchangeQueryResult> {
        return curry(YahooCurrencyExchangeQueryResult.init)
            <^> json <| ["results", "rate"]
    }
    
    public static func mockedJSON() -> Data? {
        return try? Data(contentsOf: Bundle.kit.url(forResource: "currency_exchange", withExtension: "json")!)
    }
}

public struct YahooSymbolHistoricalDataQueryResult {
    public let data: [YahooSymbolHistoricalData]
}

extension YahooSymbolHistoricalDataQueryResult: Decodable {
    public static func decode(_ json: JSON) -> Decoded<YahooSymbolHistoricalDataQueryResult> {
        return curry(YahooSymbolHistoricalDataQueryResult.init)
            <^> json <|| ["results", "quote"]
    }
    
    public static func mockedJSON() -> Data? {
        return try? Data(contentsOf: Bundle.kit.url(forResource: "currency_historical_data", withExtension: "json")!)
    }
}


