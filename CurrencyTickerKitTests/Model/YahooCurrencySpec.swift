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
        
        describe("YahooCurrency extract currencies") {
            let usdjpy = YahooCurrency(symbol: nil, name: "USD/JPY")
            it("usdjpy should return USD and JPY", closure: { 
                expect(usdjpy.currencies).to(contain("USD", "JPY"))
            })
            
            let gold = YahooCurrency(symbol: nil, name: "PALLOTINUM 1 OZ")
            it("gold should return no currencies", closure: {
                expect(gold.currencies).to(beEmpty())
            })
        }
    }
}
