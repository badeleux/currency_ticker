import Quick
import Nimble
@testable import CurrencyTickerKit
import Argo
import Runes
import SwiftDate

class YahooDecodersSpec: QuickSpec {
    override func spec() {
        describe("YahooDateDecoder json decoder") {
            it("should decode yahoo exchange rate format", closure: {
                let rawDate = "2/17/2017"
                let rawTime = "5:55pm"
                let date = YahooDateDecoders.create(rawDate, rawTime)
                expect(date).toNot(beNil())
                expect(date?.year).to(equal(2017))
                expect(date?.month).to(equal(2))
                expect(date?.day).to(equal(17))
                expect(date?.hour).to(equal(17 + Region.Local().timeZone.secondsFromGMT() / 3600))
                expect(date?.minute).to(equal(55))
                
            })
        }
    }
}
