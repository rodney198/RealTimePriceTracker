//
//  PriceFormatting.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import Foundation
import SwiftUI

enum PriceFormatting {

    //MARK: - Formats a decimal price with 2 fraction digits (e.g. "182.00").
    static func formatPrice(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    //MARK: - Returns (color, symbol) for price change: green, red, or primary.
    static func changeIndicator(for quote: StockQuote) -> (color: Color, symbol: String) {
        guard let previous = quote.previousPrice else { return (.primary, "−") }
        if quote.price > previous { return (.green, "↑") }
        if quote.price < previous { return (.red, "↓") }
        return (.primary, "−")
    }
}
