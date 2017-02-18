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
        
        describe("YahooExchange json decoder") {
            it("should decode mock data", closure: {
                let json: [String : Any] = try! JSONSerialization.jsonObject(with: YahooCurrencyExchanceRate.mockedJSON()!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                
                let rate: Decoded<YahooCurrencyExchanceRate> = (JSON(json) <| ["query", "results", "rate"])
                expect(rate.value).toNot(beNil())
                expect(rate.value!.ask).to(beGreaterThan(0))
                expect(rate.value!.rate).to(beGreaterThan(0))
                expect(rate.value!.bid).to(beGreaterThan(0))
                expect(rate.value!.date).toNot(beNil())
            })
        }
        
        describe("YahooSymbolHistoricalData json decoder") {
            it("should decode mock data", closure: {
                let json: [String : Any] = try! JSONSerialization.jsonObject(with: YahooSymbolHistoricalData.mockedJSON()!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                
                let rate: Decoded<[YahooSymbolHistoricalData]> = (JSON(json) <|| ["query", "results", "quote"])
                expect(rate.value).toNot(beNil())
                expect(rate.value).to(haveCount(2))
                expect(rate.value!.first!.high).to(beGreaterThan(0))
                expect(rate.value!.first!.close).to(beGreaterThan(0))
                expect(rate.value!.first!.low).to(beGreaterThan(0))
                expect(rate.value!.first!.open).to(beGreaterThan(0))
                expect(rate.value!.first!.date).toNot(beNil())
            })
        }
        
        describe("YahooCurrencyName extract currencies") {
            let usdjpy = YahooCurrencyName(name: "USD/JPY")
            it("usdjpy should return USD and JPY", closure: { 
                expect(usdjpy.currencies).to(contain("USD", "JPY"))
            })
            
            let gold = YahooCurrencyName(name: "PALLOTINUM 1 OZ")
            it("gold should return no currencies", closure: {
                expect(gold.currencies).to(beEmpty())
            })
        }
    }
}
