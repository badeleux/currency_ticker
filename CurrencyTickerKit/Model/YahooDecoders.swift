//
//  YahooDecoders.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 18.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes
import SwiftDate

struct YahooDateDecoders {
    static func decodeExchangeRateDate(_ json: JSON) -> Decoded<Date?> {
        return curry(YahooDateDecoders.create)
                <^> json <| "Date"
                <*> json <| "Time"
    }
    
    static func create(_ rawDate: String, _ rawTime: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: rawDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        timeFormatter.dateFormat = "hh:mma"
        let time = timeFormatter.date(from: rawTime.uppercased())
        
        if let d = date {
            return try? d.atTime(hour: time?.hour ?? 0, minute: time?.minute ?? 0, second: time?.second ?? 0)
        }
        return nil
    }
    
    static func toYahooDateOnly(_ rawDate: String) -> Decoded<Date> {
        return .fromOptional(DateFormatter.yahooDateOnly().date(from: rawDate))
    }
}

struct YahooNumberDecoders {
    static func toFloat(number: String) -> Decoded<Float> {
        return .fromOptional(Float(number))
    }
}
