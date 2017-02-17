//
//  YahooFinanceRouter.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 17.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import Moya

typealias Currency = String

protocol APIStringRepresentable {
    func apiStringRepresentation() -> String
}

enum YahooFinanceRouter {
    case currencyList
    case exchangeRate(pair: YahooCurrencyPairable)
    case historicalData(symbol: YahooCurrencySymbol, dateStart: Date, dateEnd: Date)
}

extension YahooFinanceRouter: TargetType {
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        switch self {
        case .currencyList:
            return YahooCurrency.mockedJSON() ?? Data()
        default:
            return Data()
        }
    }
    
    var task: Task {
        return .request
    }

    var baseURL: URL {
        switch self {
        case .historicalData, .exchangeRate:
            return URL(string: "https://query.yahooapis.com/")!
        case .currencyList:
            return URL(string: "https://finance.yahoo.com/")!
        }
    }
    
    var path: String {
        switch self {
        case .historicalData, .exchangeRate:
            return "/v1/public/yql"
        case .currencyList:
            return "/webservice/v1/symbols/allcurrencies/quote"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .historicalData(symbol, dateStart, dateEnd):
            let startDateString = DateFormatter.yahooDateOnly().string(from: dateStart)
            let endDateString = DateFormatter.yahooDateOnly().string(from: dateEnd)
            return ["q" : "SELECT * FROM yahoo.finance.historicaldata WHERE symbol = \"\(symbol.apiStringRepresentation())\" AND startDate = \"\(startDateString)\" AND endDate = \"\(endDateString)\""]
        case let .exchangeRate(pair):
            return ["q" : "select * from yahoo.finance.xchange where pair in (\"\(pair.apiStringRepresentation())\")"]
        case .currencyList:
            return ["format" : "json"]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    
}
