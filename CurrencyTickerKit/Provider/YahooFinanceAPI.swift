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
    let provider = ReactiveSwiftMoyaProvider<YahooFinanceRouter>()
    
    func currencyList() -> SignalProducer<YahooCurrencyList, MoyaError> {
        let result = self.provider
            .request(.currencyList)
            .flatMap(.latest, transform: { (response: Response) -> SignalProducer<YahooCurrencyList, MoyaError> in
                do {
                    let list: YahooCurrencyList = try response.mapObjectWithRootKey(rootKey: "list")
                    return .init(value: list)
                } catch let error as MoyaError {
                    return .init(error: error)
                } catch {
                    return .init(error: MoyaError.requestMapping("Unknown Error"))
                }
            })
        return result
    }
}
