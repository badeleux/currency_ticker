//
//  EditFavouriteCurrenciesViewController.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import CurrencyTickerKit
import ReactiveSwift

class EditFavouriteCurrenciesViewController: UITableViewController {
    static let CellIdentifier = "CurrencyCell"
    
    let currencyCodes = Locale.isoCurrencyCodes
    let commonCurrencyCodes = Locale.commonISOCurrencyCodes
    let favouriteCodes = MutableProperty<[CurrencyCode]>(FavouriteCurrency.shared.get())
    
//    private let (lifetime, token) = Lifetime.make()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favouriteCodes <~ FavouriteCurrency.shared
            .stream
        favouriteCodes.signal
            .observeValues { [weak self] _ in
                self?.tableView.reloadData()
            }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditFavouriteCurrenciesViewController.CellIdentifier, for: indexPath)
        let currencyCode = self.currencyCodes(forSection: indexPath.section)[indexPath.row]
        cell.textLabel?.text = currencyCode
        cell.accessoryType = self.favouriteCodes.value.contains(currencyCode) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencyCodes(forSection: section).count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("fav_currency_common_currencies_header", comment: "")
        default:
            return NSLocalizedString("fav_currency_all_currencies_header", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currencyCode = self.currencyCodes(forSection: indexPath.section)[indexPath.row]
        let isFavourite = self.favouriteCodes.value.contains(currencyCode)
        if isFavourite {
            FavouriteCurrency.shared.remove(currency: currencyCode)
        }
        else {
            FavouriteCurrency.shared.add(currency: currencyCode)
        }
    }
    
    func currencyCodes(forSection section: Int) -> [CurrencyCode] {
        switch section {
        case 0:
            return self.commonCurrencyCodes
        default:
            return self.currencyCodes
        }
    }
    
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
