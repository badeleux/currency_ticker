//
//  YahooFinance.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 17.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

// MARK: - Constants

struct YahooConstants {
    static let USD = "USD"
}

// MARK: - YahooCurrencySymbol

public struct YahooCurrencySymbol: APIStringQueryRepresentable {
    public let currency: Currency
    
    func apiStringQueryRepresentation() -> String {
        return self.currency + "=X"
    }
}

extension YahooCurrencySymbol: Decodable {
    static func create(rawSymbol: String) -> YahooCurrencySymbol? {
        let components = rawSymbol.components(separatedBy: "=")
        if components.count == 2 && components[1] == "X"  {
            return YahooCurrencySymbol(currency: components[0])
        }
        return nil
    }
    
    
    public static func decode(_ json: JSON) -> Decoded<YahooCurrencySymbol> {
        switch json {
        case let JSON.string(s):
            if let rawSymbol = s.removingPercentEncoding,
                let symbol = YahooCurrencySymbol.create(rawSymbol: rawSymbol) {
                return .success(symbol)
            }
            else {
                return .failure(.custom("Unable to parse string to symbol" + s))
            }
        default:
            return .failure(DecodeError.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

// MARK: - YahooCurrencyName

public struct YahooCurrencyName {
    public let name: String
    
    public var currencies: Set<Currency> {
        let components = name.components(separatedBy: "/")
        if components.count == 2 {
            return Set(components)
        }
        else {
            return Set()
        }
    }
}

extension YahooCurrencyName: Decodable {
    public static func decode(_ json: JSON) -> Decoded<YahooCurrencyName> {
        switch json {
        case let .string(s):
            return .success(YahooCurrencyName(name: s))
        default:
            return .failure(DecodeError.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

// MARK: - YahooCurrencyPair

public protocol YahooCurrencyPairable {
    var from: Currency { get }
    var to: Currency { get }
}

extension YahooCurrencyPairable {
    func apiStringQueryRepresentation() -> String {
        return from + to
    }
    
    public static func create(rawPair: String) -> YahooUSDCurrencyPair? {
        let components = rawPair.components(separatedBy: "/")
        if components.first == YahooConstants.USD && components.count == 2 {
            return YahooUSDCurrencyPair(to: components[1])
        }
        return nil
    }
}

public struct YahooCurrencyPair: YahooCurrencyPairable, APIStringQueryRepresentable {
    public let from: Currency
    public let to: Currency
}

public struct YahooUSDCurrencyPair: YahooCurrencyPairable, APIStringQueryRepresentable {
    public let from: Currency = YahooConstants.USD
    public let to: Currency
}

// MARK: - YahooCurrency

public struct YahooCurrency {
    public let symbol: YahooCurrencySymbol?
    public let name: YahooCurrencyName?
}

extension YahooCurrency: Decodable {
    public static func decode(_ json: JSON) -> Decoded<YahooCurrency> {
        return curry(YahooCurrency.init)
            <^> json <|? ["resource", "fields", "symbol"]
            <*> json <|? ["resource", "fields", "name"]
    }
}

// MARK: - YahooCurrencyExchangeRate

public struct YahooCurrencyExchanceRate {
    public let name: YahooCurrencyName
    public let rate: Float
    public let date: Date?
    public let ask: Float
    public let bid: Float
}

extension YahooCurrencyExchanceRate: Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<YahooCurrencyExchanceRate> {
        let a = curry(YahooCurrencyExchanceRate.init)
            <^> json <| "Name"
            <*> (json <| "Rate" >>- YahooNumberDecoders.toFloat)
            <*> YahooDateDecoders.decodeExchangeRateDate(json)
        return a <*> (json <| "Ask" >>- YahooNumberDecoders.toFloat)
            <*> (json <| "Bid" >>- YahooNumberDecoders.toFloat)
    }
}

// MARK: - YahooSymbolHistoricalData

public struct YahooSymbolHistoricalData {
    public let symbol: YahooCurrencySymbol
    public let date: Date
    public let open: Float
    public let high: Float
    public let low: Float
    public let close: Float
}

extension YahooSymbolHistoricalData: Decodable {
    public static func decode(_ json: JSON) -> Decoded<YahooSymbolHistoricalData> {
        return curry(YahooSymbolHistoricalData.init)
            <^> json <| "Symbol"
            <*> (json <| "Date" >>- YahooDateDecoders.toYahooDateOnly)
            <*> (json <| "Open" >>- YahooNumberDecoders.toFloat)
            <*> (json <| "High" >>- YahooNumberDecoders.toFloat)
            <*> (json <| "Low" >>- YahooNumberDecoders.toFloat)
            <*> (json <| "Close" >>- YahooNumberDecoders.toFloat)
    }
    
    public static func mockedJSON() -> Data? {
        return try? Data(contentsOf: Bundle.kit.url(forResource: "currency_historical_data", withExtension: "json")!)
    }
}
