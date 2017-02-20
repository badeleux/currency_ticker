import Quick
import Nimble
@testable import CurrencyTickerKit

class DateFormattersSpec: QuickSpec {
    override func spec() {
        describe("yahooDateOnly formatter") {
            it("should convert date to string", closure: { 
                let date = Date(timeIntervalSince1970: 1285346985)
                expect(DateFormatter.yahooDateOnly().string(from: date)).to(equal("2010-09-24"))
            })
        }
    }
}
