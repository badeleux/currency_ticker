//
//  CurrencyTableViewCell.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 21.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import ChameleonFramework


class CurrencyTableViewCell: UITableViewCell {
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    var cellTheme: CellTheme? {
        didSet {
            if let theme = self.cellTheme {
                self.contentView.backgroundColor = theme.bgColor
                self.currencyCodeLabel.textColor = theme.bgContrastColor
                self.rateLabel.textColor = theme.bgContrastColor
                self.lastUpdatedLabel.textColor = theme.bgContrastColor
                self.selectedBackgroundView?.backgroundColor = theme.selectionColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectionView = UIView(frame: self.contentView.frame)
        self.selectedBackgroundView = selectionView
    }
}
