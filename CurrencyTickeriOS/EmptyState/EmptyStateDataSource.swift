//
//  EmptyStateDataSource.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 23.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import DZNEmptyDataSet
import TextAttributes
import ReactiveSwift
import CurrencyTickerKit
import Result

enum EmptyStateScreen {
    case dashboard, chart
}

enum EmptyListState {
    case noData, loading, error(message: String)
}

class EmptyStateDataSource: NSObject {
    let screen: EmptyStateScreen
    var state = MutableProperty<EmptyListState>(.noData)
    
    init(screen: EmptyStateScreen) {
        self.screen = screen
    }
}

extension LoadableViewModel {
    func emptyListState() -> Signal<EmptyListState, NoError> {
        let errorState = self.error.map { error in EmptyListState.error(message: error.localizedDescription) }
        let loading = self.loading
            .filter { $0 }
            .map { _ in EmptyListState.loading }
        let state = Signal<EmptyListState, NoError>.merge(errorState, loading)
        return state
    }
}

extension EmptyStateDataSource: DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let titleAttributes = TextAttributes()
            .font(UIFont.titleFont)
            .alignment(.center)
        
        switch self.state.value {
        case .noData:
            return NSAttributedString(string: NSLocalizedString("empty_state_no_data", comment: ""), attributes: titleAttributes)
        case .loading:
            return NSAttributedString(string: NSLocalizedString("empty_state_loading", comment: ""), attributes: titleAttributes)
        case .error:
            return NSAttributedString(string: NSLocalizedString("empty_state_error", comment: ""), attributes: titleAttributes)
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let descriptionAttributes = TextAttributes()
            .font(UIFont.descriptionFont)
            .alignment(.center)
        
        switch self.state.value {
        case let .error(message):
            return NSAttributedString(string: message, attributes: descriptionAttributes)
        default:
            return NSAttributedString()
        }
    }
}
