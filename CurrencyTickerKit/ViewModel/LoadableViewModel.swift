//
//  LoadableViewModel.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 22.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

public protocol LoadableViewModel {
    associatedtype E: Error
    var loading: Signal<Bool, NoError> { get }
    var error: Signal<E, NoError> { get }
    var noData: Signal<Bool, NoError> { get }
}

extension LoadableViewModel {
    func loadableProducer<T>(producer: SignalProducer<T, E>) -> (Signal<Bool, NoError>, Signal<E, NoError>, SignalProducer<T, NoError>) {
        let loadingProperty = MutableProperty<Bool>(false)
        let errorProperty = MutableProperty<E?>(nil)
        
        let errorSignal = errorProperty.signal.skipNil()
        let newProducer = producer
            .forwardLoading(property: loadingProperty)
            .forwardError(property: errorProperty)
            .ignoreError()
        return (loadingProperty.signal, errorSignal, newProducer)
    }
}

extension SignalProducerProtocol {

    func forwardLoading(property: MutableProperty<Bool>) -> SignalProducer<Value, Error> {
        return self.on(started: { 
            property.value = true
        }, failed: { _ in
            property.value = false
        }, completed: { 
            property.value = false
        })
    }
    
    func forwardError(property: MutableProperty<Error?>) -> SignalProducer<Value, Error> {
        return self.on(failed: {
            property.value = $0
        })
    }
}
