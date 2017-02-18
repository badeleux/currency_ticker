import Quick
import Nimble
@testable import CurrencyTickerKit
import Moya
import Moya_Argo
import Moya

class YahooFinanceRouterSpec: QuickSpec {
    override func spec() {
        describe("APIStringRepresentable") {
            it("CurrencySymbol -> String", closure: {
                expect(YahooCurrencySymbol(currency: "USD").apiStringQueryRepresentation()).to(equal("USD=X"))
            })
            
            it("CurrencyPair -> String", closure: {
                expect(YahooUSDCurrencyPair(to: "EUR").apiStringQueryRepresentation()).to(equal("USDEUR"))
            })
        }
        
        describe("test requests") { 
            it("should return", closure: { 
                let api = YahooFinanceAPI()
                waitUntil(timeout: 6.0, action: { done in
                    api.currencyList()
                        .on(value: { (list: YahooCurrencyList) in
                            done()
                        })
                        .logEvents()
                        .start()
                })
                
            })
        }
    }
}
