import Quick
import Nimble
@testable import CurrencyTickerKit
import Argo
import Runes

class YahooCurrencySpec: QuickSpec {
    override func spec() {
        describe("YahooCurrency json decoder") { 
            it("should decode mock data", closure: { 
                let json: [String : Any] = try! JSONSerialization.jsonObject(with: YahooCurrency.mockedJSON()!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                
                let currencies: Decoded<[YahooCurrency]> = (JSON(json) <|| ["list", "resources"])
                expect(currencies.value).toNot(beNil())
                expect(currencies.value).to(haveCount(188))
            })
        }
    }
}
