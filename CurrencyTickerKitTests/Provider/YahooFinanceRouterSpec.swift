import Quick
import Nimble
@testable import CurrencyTickerKit

class YahooFinanceRouterSpec: QuickSpec {
    override func spec() {
        describe("APIStringRepresentable") {
            it("CurrencySymbol -> String", closure: {
                expect(YahooCurrencySymbol(currency: "USD").apiStringRepresentation()).to(equal("USD=X"))
            })
            
            it("CurrencyPair -> String", closure: {
                expect(YahooCurrencyPair(from: "USD", to: "EUR").apiStringRepresentation()).to(equal("USDEUR"))
            })
        }
    }
}
