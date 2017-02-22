import Quick
import Nimble
@testable import CurrencyTickerKit
import ReactiveSwift
import Result

class TestLoadableViewModel: LoadableViewModel {
    let error: Signal<NSError, NoError>
    let loading: Signal<Bool, NoError>
    
    init() {
        self.error = Signal.empty
        self.loading = Signal.empty
    }
}

class LoadableViewModelSpec: QuickSpec {
    override func spec() {
        let testVM = TestLoadableViewModel()
        describe("loadable view model") {
            it("emits loading values", closure: { 
                let loadingRequest = SignalProducer<Int, NSError>.init(value: 1).delay(2.0, on: QueueScheduler.main)
                let tuples = testVM.loadableProducer(producer: loadingRequest)
                var loadingValues = [Bool]()
                
                tuples.0.observeValues({ (x: Bool) in
                    loadingValues.append(x)
                })
                tuples.2.start()
                expect(loadingValues).toEventually(equal([true,false]), timeout: 3.0)
            })
            
            it("emits error values", closure: { 
                let failedRequest = SignalProducer<Int, NSError>.init(error: NSError(domain: "", code: 1, userInfo: nil))
                    .delay(2.0, on: QueueScheduler.main)
                let tuples = testVM.loadableProducer(producer: failedRequest)
                
                var loadingValues = [Bool]()
                var errorValue: NSError? = nil
                
                tuples.0.observeValues({ (x: Bool) in
                    loadingValues.append(x)
                })
                tuples.1.observeValues({ (x: NSError) in
                    errorValue = x
                })
                tuples.2.start()
                expect(loadingValues).toEventually(equal([true,false]), timeout: 3.0)
                expect(errorValue).toEventuallyNot(beNil(), timeout: 3.0)
                
            })
        }
    }
}
