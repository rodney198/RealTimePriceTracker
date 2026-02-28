//
//  SymbolDetailViewModel.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import SwiftUI
import Combine

@MainActor
final class SymbolDetailViewModel: ObservableObject {
    let symbol: String
    private let priceFeed: PriceFeedService
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var quote: StockQuote?

    init(priceFeed: PriceFeedService, symbol: String) {
        self.priceFeed = priceFeed
        self.symbol = symbol
        self.quote = priceFeed.quotes.first { $0.symbol == symbol }
        priceFeed.$quotes
            .map { [symbol] quotes in quotes.first { $0.symbol == symbol } }
            .receive(on: DispatchQueue.main)
            .assign(to: &$quote)
    }
}
