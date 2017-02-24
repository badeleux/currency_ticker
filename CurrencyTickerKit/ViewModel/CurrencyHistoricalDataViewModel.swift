//
//  CurrencyHistoricalDataViewModel.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import SwiftDate
import ReactiveSwift
import Result

struct ChartSettings {
    static let XAxisValues = 20
    static let YAxisValues = 20
}

public protocol CandleStickData {
    var open: Float { get }
    var high: Float { get }
    var low: Float { get }
    var close: Float { get }
    var date: Date { get }
}

public struct CurrencyChartData<T: CandleStickData> {
    public let points: [T]
    public let xAxisDates: [Date]
    public let yAxisValues: [Float]
}

struct ChartTimePeriod {
    let startDate: Date
    let endDate: Date
    
    func days() -> [Date] {
        return Date.dates(between: self.startDate, and: self.endDate, increment: 1.day)
    }
}

protocol CurrencyHistoricalDataViewModelInputs {
    func configureWith(currencyCode: CurrencyCode)
    func timePeriod(start: Date, end: Date)
    func timePeriod(last: DateComponents)
}

protocol CurrencyHistoricalDataViewModelOutputs {
    associatedtype T: CandleStickData
    var chartData: Signal<CurrencyChartData<T>, NoError> { get }
}

public class CurrencyHistoricalDataViewModel<T: CandleStickData>: CurrencyHistoricalDataViewModelInputs, CurrencyHistoricalDataViewModelOutputs {
    
    // MARK: - Inputs
    let currencyCode = MutableProperty<CurrencyCode?>(nil)
    let timePeriod = MutableProperty<ChartTimePeriod?>(nil)
    
    public func configureWith(currencyCode: CurrencyCode) {
        self.currencyCode.value = currencyCode
    }
    
    public func timePeriod(start: Date, end: Date) {
        self.timePeriod.value = ChartTimePeriod(startDate: start, endDate: end)
    }
    
    public func timePeriod(last: DateComponents) {
        self.timePeriod(start: Date() - last, end: Date())
    }
    
    // MARK: - Outputs
    
    public let chartData: Signal<CurrencyChartData<T>, NoError>
    
    init<R: HistoricalDataRetriever>(api: R) where R.T == T {
        let historicalData = self.currencyCode.signal.skipNil().combineLatest(with: self.timePeriod.signal.skipNil()).flatMap(.latest) { (tuple: (currencyCode: CurrencyCode, period: ChartTimePeriod)) -> SignalProducer<[T], NoError> in
            return api.currencyHistoricalData(currencyCode: tuple.currencyCode, start: tuple.period.startDate, end: tuple.period.endDate)
                .ignoreError()
        }
        self.chartData = historicalData.signal.combineLatest(with: self.timePeriod.signal.skipNil())
            .map({ (tuple: (data: [T], period: ChartTimePeriod)) -> CurrencyChartData<T> in
                let yAxisValues = CurrencyHistoricalDataViewModel.axisValues(data: tuple.data)
                return CurrencyChartData(points: tuple.data, xAxisDates: tuple.period.days(), yAxisValues: yAxisValues)
            })
    }
    
    static func axisValues(data: [T], values: Int = ChartSettings.XAxisValues) -> [Float] {
        let maxMin = data.reduce((Float(Int.min), Float(Int.max)), { (maxMin: (Float, Float), data: T) -> (Float, Float) in
            return (max(data.high, maxMin.0), min(maxMin.1, data.low))
        })
        let step = ((maxMin.0 - maxMin.1) / Float(values))
        let result = stride(from: maxMin.1, to: maxMin.0, by: step)
        return result.sorted()
    }
}


