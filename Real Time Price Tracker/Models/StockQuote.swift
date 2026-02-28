//
//  StockQuote.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 27/02/26.
//

import Foundation

enum PriceChangeDirection {
    case up
    case down
    case unchanged
}

struct StockQuote: Identifiable, Equatable {
    var id: String { symbol }
    let symbol: String
    var price: Decimal
    var previousPrice: Decimal?
    let description: String
    var lastChangeDirection: PriceChangeDirection?
    var lastChangeDate: Date?

    init(symbol: String, price: Decimal, previousPrice: Decimal? = nil, description: String, lastChangeDirection: PriceChangeDirection? = nil, lastChangeDate: Date? = nil) {
        self.symbol = symbol
        self.price = price
        self.previousPrice = previousPrice
        self.description = description
        self.lastChangeDirection = lastChangeDirection
        self.lastChangeDate = lastChangeDate
    }
}
