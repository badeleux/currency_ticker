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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColor = RandomFlatColorWithShade(.light)
        let bgContrastColor = ContrastColorOf(bgColor, returnFlat: true)
        self.contentView.backgroundColor = bgColor
        self.currencyCodeLabel.textColor = bgContrastColor
        self.rateLabel.textColor = bgContrastColor
        
        let selectionView = UIView(frame: self.contentView.frame)
        selectionView.backgroundColor = bgColor.darken(byPercentage: 0.1)
        self.selectedBackgroundView = selectionView
        
        self.lastUpdatedLabel.textColor = bgContrastColor
    }
}
