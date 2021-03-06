import Quick
import Nimble
@testable import CurrencyTickerKit
import Moya
import Moya_Argo
import Moya
import SwiftDate

class YahooFinanceRouterSpec: QuickSpec {
    override func spec() {
        describe("APIStringRepresentable") {
            it("CurrencySymbol -> String", closure: {
                expect(YahooCurrencySymbol(code: "USD").apiStringQueryRepresentation()).to(equal("USD=X"))
            })
            
            it("CurrencyPair -> String", closure: {
                expect(YahooUSDCurrencyPair(to: "EUR").apiStringQueryRepresentation()).to(equal("USDEUR"))
            })
        }
        
        describe("test requests") { 
            it("currency list", closure: {
                let api = YahooFinanceAPI.shared
                waitUntil(timeout: 6.0, action: { done in
                    api.currencyList()
                        .on(value: { (list: YahooCurrencyList) in
                            done()
                        })
                        .logEvents()
                        .start()
                })
                
            })
            
            it("currency exchage", closure: {
                let api = YahooFinanceAPI.shared
                waitUntil(timeout: 6.0, action: { done in
                    api.currenciesExchange(pairs: [YahooCurrencyPair(from: "USD", to: "PLN"), YahooCurrencyPair(from: "EUR", to: "PLN")])
                        .on(value: { (list: YahooCurrencyExchangeQueryResults) in
                            expect(list.rates).to(haveCount(2))
                            done()
                        })
                        .logEvents()
                        .start()
                })
                
            })
            
            it("currency historical data query", closure: {
                let api = YahooFinanceAPI.shared
                waitUntil(timeout: 6.0, action: { done in
                    api.currencyHistoricalData(symbol: YahooCurrencySymbol(code: "PLN"), start: Date() - 2.weeks, end: Date())
                        .on(value: { (list: YahooSymbolHistoricalDataQueryResult) in
                            done()
                        })
                        .logEvents()
                        .start()
                })
                
            })
        }
    }
}
