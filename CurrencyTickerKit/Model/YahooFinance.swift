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

struct YahooCurrencySymbol: APIStringQueryRepresentable {
    let currency: Currency
    
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
    
    
    static func decode(_ json: JSON) -> Decoded<YahooCurrencySymbol> {
        switch json {
        case let JSON.string(s):
            if let symbol = YahooCurrencySymbol.create(rawSymbol: s) {
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

struct YahooCurrencyName {
    let name: String
    
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
    static func decode(_ json: JSON) -> Decoded<YahooCurrencyName> {
        switch json {
        case let .string(s):
            return .success(YahooCurrencyName(name: s))
        default:
            return .failure(DecodeError.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

// MARK: - YahooCurrencyPair

protocol YahooCurrencyPairable {
    var from: Currency { get }
    var to: Currency { get }
}

extension YahooCurrencyPairable {
    func apiStringQueryRepresentation() -> String {
        return from + to
    }
    
    static func create(rawPair: String) -> YahooUSDCurrencyPair? {
        let components = rawPair.components(separatedBy: "/")
        if components.first == YahooConstants.USD && components.count == 2 {
            return YahooUSDCurrencyPair(to: components[1])
        }
        return nil
    }
}

struct YahooCurrencyPair: YahooCurrencyPairable, APIStringQueryRepresentable {
    let from: Currency
    let to: Currency
}

struct YahooUSDCurrencyPair: YahooCurrencyPairable, APIStringQueryRepresentable {
    let from: Currency = YahooConstants.USD
    let to: Currency
}

// MARK: - YahooCurrency

struct YahooCurrency {
    let symbol: YahooCurrencySymbol?
    let name: YahooCurrencyName?
    
    static func mockedJSON() -> Data? {
        return try? Data(contentsOf: Bundle.kit.url(forResource: "currency_list", withExtension: "json")!)
    }
}

extension YahooCurrency: Decodable {
    static func decode(_ json: JSON) -> Decoded<YahooCurrency> {
        return curry(YahooCurrency.init)
            <^> json <|? ["resource", "fields", "symbol"]
            <*> json <|? ["resource", "fields", "name"]
    }
}

// MARK: - YahooCurrencyExchangeRate

struct YahooCurrencyExchanceRate {
    let name: YahooCurrencyName
    let rate: Float
    let date: Date?
    let ask: Float
    let bid: Float
}

extension YahooCurrencyExchanceRate: Decodable {
    
    
    static func decode(_ json: JSON) -> Decoded<YahooCurrencyExchanceRate> {
        let a = curry(YahooCurrencyExchanceRate.init)
            <^> json <| "Name"
            <*> (json <| "Rate" >>- YahooNumberDecoders.toFloat)
            <*> YahooDateDecoders.decodeExchangeRateDate(json)
        return a <*> (json <| "Ask" >>- YahooNumberDecoders.toFloat)
            <*> (json <| "Bid" >>- YahooNumberDecoders.toFloat)
    }
    
    static func mockedJSON() -> Data? {
        return try? Data(contentsOf: Bundle.kit.url(forResource: "currency_exchange", withExtension: "json")!)
    }
}
