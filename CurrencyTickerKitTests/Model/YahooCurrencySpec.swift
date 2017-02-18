import Quick
import Nimble
@testable import CurrencyTickerKit
import Argo
import Runes

class YahooCurrencySpec: QuickSpec {
    override func spec() {
        describe("YahooCurrency json decoder") { 
            it("should decode mock data", closure: { 
                let json: [String : Any] = try! JSONSerialization.jsonObject(with: YahooCurrencyList.mockedJSON()!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                
                let currencies: Decoded<YahooCurrencyList> = JSON(json) <| "list"
                expect(currencies.value).toNot(beNil())
                expect(currencies.value?.currencies).to(haveCount(188))
            })
        }
        
        describe("YahooExchange json decoder") {
            it("should decode mock data", closure: {
                let json: [String : Any] = try! JSONSerialization.jsonObject(with: YahooCurrencyExchangeQueryResult.mockedJSON()!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                
                let rate: Decoded<YahooCurrencyExchangeQueryResult> = JSON(json) <| "query"
                expect(rate.value).toNot(beNil())
                expect(rate.value!.rate.ask).to(beGreaterThan(0))
                expect(rate.value!.rate.rate).to(beGreaterThan(0))
                expect(rate.value!.rate.bid).to(beGreaterThan(0))
                expect(rate.value!.rate.date).toNot(beNil())
            })
        }
        
        describe("YahooSymbolHistoricalData json decoder") {
            it("should decode mock data", closure: {
                let json: [String : Any] = try! JSONSerialization.jsonObject(with: YahooSymbolHistoricalDataQueryResult.mockedJSON()!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                
                let rate: Decoded<YahooSymbolHistoricalDataQueryResult> = JSON(json) <| "query"
                expect(rate.value).toNot(beNil())
                expect(rate.value?.data).to(haveCount(2))
                expect(rate.value!.data.first!.high).to(beGreaterThan(0))
                expect(rate.value!.data.first!.close).to(beGreaterThan(0))
                expect(rate.value!.data.first!.low).to(beGreaterThan(0))
                expect(rate.value!.data.first!.open).to(beGreaterThan(0))
                expect(rate.value!.data.first!.date).toNot(beNil())
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
