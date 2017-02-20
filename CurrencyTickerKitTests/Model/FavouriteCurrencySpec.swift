import Quick
import Nimble
@testable import CurrencyTickerKit

extension YahooCurrency {
    static func generateTest() -> YahooCurrency {
        return YahooCurrency(symbol: YahooCurrencySymbol(currency: ProcessInfo.processInfo.globallyUniqueString), name: YahooCurrencyName(name: ProcessInfo.processInfo.globallyUniqueString))
    }
}

class FavouriteCurrencySpec: QuickSpec {
    override func spec() {
        describe("Favourite Currency") {
            let testDefaults = UserDefaults(suiteName: ProcessInfo.processInfo.globallyUniqueString)!
            let favCurrency = FavouriteCurrency(userDefaults: testDefaults)
            it("is not defined on first run", closure: {
                expect(favCurrency.isDefined()).toNot(beTrue())
            })
            
            it("is defined after first value is set", closure: {
                favCurrency.add(currency: YahooCurrency.generateTest())
                expect(favCurrency.isDefined()).to(beTrue())
                expect(favCurrency.get()).to(haveCount(1))
                favCurrency.add(currency: YahooCurrency.generateTest())
                expect(favCurrency.get()).to(haveCount(2))
                
                let testValue = YahooCurrency.generateTest()
                favCurrency.set(currency: [testValue])
                expect(favCurrency.get()).to(haveCount(1))
                expect(favCurrency.get().first!.name!).to(equal(testValue.name!))
                expect(favCurrency.get().first!.symbol!).to(equal(testValue.symbol!))
            })
        }
    }
}
