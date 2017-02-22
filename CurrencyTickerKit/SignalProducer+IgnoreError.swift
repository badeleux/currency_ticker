//
//  SignalProducer+IgnoreError.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 21.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

extension SignalProducerProtocol {
    public func ignoreError() -> SignalProducer<Value, NoError> {
        return self.producer.flatMapError { _ in SignalProducer<Value, NoError>.empty }
    }
}
