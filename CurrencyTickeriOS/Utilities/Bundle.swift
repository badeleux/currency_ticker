//
//  Bundle.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation

extension Bundle {
    static var iosFramework: Bundle {
        return Bundle(for: DashboardViewController.self)
    }
}
