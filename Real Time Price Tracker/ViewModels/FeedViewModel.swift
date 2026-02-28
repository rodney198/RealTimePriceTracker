//
//  FeedViewModel.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import SwiftUI
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    private let priceFeed: PriceFeedService
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var sortedQuotes: [StockQuote] = []
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var isFeedRunning: Bool = false

    init(priceFeed: PriceFeedService) {
        self.priceFeed = priceFeed
        self.sortedQuotes = priceFeed.sortedQuotes
        self.isConnected = priceFeed.isConnected
        self.isFeedRunning = priceFeed.isFeedRunning
        priceFeed.$quotes
            .map { $0.sorted { $0.price > $1.price } }
            .receive(on: DispatchQueue.main)
            .assign(to: &$sortedQuotes)
        priceFeed.$isConnected.assign(to: &$isConnected)
        priceFeed.$isFeedRunning.assign(to: &$isFeedRunning)
    }

    func startFeed() {
        priceFeed.startFeed()
    }

    func stopFeed() {
        priceFeed.stopFeed()
    }
}
