import Quick
import Nimble
@testable import CurrencyTickerKit

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
    }
}
