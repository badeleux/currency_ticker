//
//  DateFormatters.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 17.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation

extension DateFormatter {
    public static func yahooDateOnly() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }    
}
