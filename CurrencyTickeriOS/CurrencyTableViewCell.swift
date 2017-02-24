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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColor = RandomFlatColorWithShade(.light)
        self.contentView.backgroundColor = bgColor
        self.currencyCodeLabel.textColor = ContrastColorOf(bgColor, returnFlat: true)
        self.rateLabel.textColor = ContrastColorOf(bgColor, returnFlat: true)
        
        let selectionView = UIView(frame: self.contentView.frame)
        selectionView.backgroundColor = bgColor.darken(byPercentage: 0.1)
        self.selectedBackgroundView = selectionView
    }
}
