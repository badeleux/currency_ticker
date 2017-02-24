import Quick
import Nimble
@testable import CurrencyTickerKit

struct TestCandleStickData: CandleStickData {
    let open: Float
    let high: Float
    let low: Float
    let close: Float
}

class CurrencyHistoricalDataViewModelSpec: QuickSpec {
    override func spec() {
        describe("ChartViewModel") { 
            it("generates axis values", closure: { 
                let chartData = (1...100)
                    .map { Float($0) }
                    .map { TestCandleStickData(open: $0, high: $0 + 0.75, low: $0, close: $0) }
                let axisData = CurrencyHistoricalDataViewModel.axisValues(data: chartData, values: 20)
                expect(axisData).to(haveCount(20))
                expect(axisData.max()).to(beGreaterThan(100.74))
                expect(axisData.min()).to(beLessThan(1.01))
            })
        }
    }
}
