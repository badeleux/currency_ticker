//
//  YahooFinance.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 17.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import Argo
import Ogra
import Curry
import Runes

// MARK: - Constants

struct YahooConstants {
    static let USD = "USD"
    static let EUR = "EUR"
}

// MARK: - YahooCurrencySymbol

public struct YahooCurrencySymbol: APIStringQueryRepresentable, Equatable {
    public let code: CurrencyCode
    
    func apiStringQueryRepresentation() -> String {
        return self.code + "=X"
    }
}

public func ==(c1: YahooCurrencySymbol, c2: YahooCurrencySymbol) -> Bool {
    return c1.code == c2.code
}

extension YahooCurrencySymbol: Decodable, Encodable {
    static func create(rawSymbol: String) -> YahooCurrencySymbol? {
        let components = rawSymbol.components(separatedBy: "=")
        if components.count == 2 && components[1] == "X"  {
            return YahooCurrencySymbol(code: components[0])
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
    
    public func encode() -> JSON {
        return JSON.string(self.code + "=X")
    }
}

// MARK: - YahooCurrencyName

public struct YahooCurrencyName: Equatable {
    public let name: String
    
    public var currencies: Set<CurrencyCode> {
        let components = name.components(separatedBy: "/")
        if components.count == 2 {
            return Set(components)
        }
        else {
            return Set()
        }
    }
    
    public var toPair: YahooCurrencyPair? {
        let components = name.components(separatedBy: "/")
        if components.count == 2 {
            return YahooCurrencyPair(from: components.first!, to: components[1])
        }
        return nil
    }
}

public func ==(c1: YahooCurrencyName, c2: YahooCurrencyName) -> Bool {
    return c1.name == c2.name
}

extension YahooCurrencyName: Decodable, Encodable {
    public static func decode(_ json: JSON) -> Decoded<YahooCurrencyName> {
        switch json {
        case let .string(s):
            return .success(YahooCurrencyName(name: s))
        default:
            return .failure(DecodeError.typeMismatch(expected: "String", actual: json.description))
        }
    }
    
    public func encode() -> JSON {
        return JSON.string(self.name)
    }
}

// MARK: - YahooCurrencyPair

public protocol YahooCurrencyPairable {
    var from: CurrencyCode { get }
    var to: CurrencyCode { get }
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
    
    func toYahooCurrencyName() -> YahooCurrencyName {
        return YahooCurrencyName(name: self.from + "/" + self.to)
    }
}

public struct YahooCurrencyPair: YahooCurrencyPairable, APIStringQueryRepresentable {
    public let from: CurrencyCode
    public let to: CurrencyCode
}

public struct YahooUSDCurrencyPair: YahooCurrencyPairable, APIStringQueryRepresentable {
    public let from: CurrencyCode = YahooConstants.USD
    public let to: CurrencyCode
}

public struct YahooEURCurrencyPair: YahooCurrencyPairable, APIStringQueryRepresentable {
    public let from: CurrencyCode = YahooConstants.EUR
    public let to: CurrencyCode
}

// MARK: - YahooCurrency

public struct YahooCurrency: Equatable {
    public let symbol: YahooCurrencySymbol?
    public let name: YahooCurrencyName?
    
    public static func currency(currencyCode: CurrencyCode) -> YahooCurrency {
        return YahooCurrency(symbol: YahooCurrencySymbol(code: currencyCode), name: YahooUSDCurrencyPair(to: currencyCode).toYahooCurrencyName())
    }
}

public func ==(c1: YahooCurrency, c2: YahooCurrency) -> Bool {
    return c1.symbol == c2.symbol && c1.name == c2.name
}

extension YahooCurrency: Decodable, Encodable {
    public static func decode(_ json: JSON) -> Decoded<YahooCurrency> {
        return curry(YahooCurrency.init)
            <^> json <|? ["resource", "fields", "symbol"]
            <*> json <|? ["resource", "fields", "name"]
    }
    
    public func encode() -> JSON {
        return JSON.object(["resource" : JSON.object([ "fields" : JSON.object(["symbol" : symbol?.encode() ?? JSON.string(""),
                                                                               "name" : self.name?.encode() ?? JSON.string("")])
                                         ])
            ])
    }
}

// MARK: - YahooCurrencyExchangeRate

public struct YahooCurrencyExchanceRate {
    public let name: YahooCurrencyName
    public let rate: Float?
    public let date: Date?
    public let ask: Float?
    public let bid: Float?
}

extension YahooCurrencyExchanceRate: Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<YahooCurrencyExchanceRate> {
        let a = curry(YahooCurrencyExchanceRate.init)
            <^> json <| "Name"
            <*> (json <|? "Rate" >>- YahooNumberDecoders.optToFloat)
            <*> YahooDateDecoders.decodeExchangeRateDate(json)
        return a <*> (json <|? "Ask" >>- YahooNumberDecoders.optToFloat)
            <*> (json <|? "Bid" >>- YahooNumberDecoders.optToFloat)
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

extension YahooSymbolHistoricalData: CandleStickData { } 

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
