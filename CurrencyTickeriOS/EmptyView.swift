//
//  EmptyView.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import UIKit

class EmptyView: UITableView {
    
    let emptyStateDataSource: EmptyStateDataSource
    
    init(frame: CGRect, screen: EmptyStateScreen) {
        self.emptyStateDataSource = EmptyStateDataSource(screen: screen)
        super.init(frame: frame, style: .plain)
        self.emptyDataSetSource = emptyStateDataSource
        self.emptyStateDataSource.state.signal.observeValues { [weak self] _ in self?.reloadEmptyDataSet() }
        self.tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
