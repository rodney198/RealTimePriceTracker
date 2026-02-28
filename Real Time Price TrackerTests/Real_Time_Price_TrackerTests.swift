//
//  Real_Time_Price_TrackerTests.swift
//  Real Time Price TrackerTests
//
//  Created by Rodney Pinto on 27/02/26.
//

import XCTest
@testable import Real_Time_Price_Tracker

final class Real_Time_Price_TrackerTests: XCTestCase {

    // MARK: - WebSocketPriceMessage

    func testWebSocketPriceMessageDecoding_validJSON() throws {
        let json = """
        {"symbol": "AAPL", "price": 182.50}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(WebSocketPriceMessage.self, from: json)
        XCTAssertEqual(decoded.symbol, "AAPL")
        XCTAssertEqual(decoded.price, 182.50)
    }

    func testWebSocketPriceMessageDecoding_invalidJSON_fails() {
        let json = """
        {"symbol": "AAPL"}
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(WebSocketPriceMessage.self, from: json))
    }

    func testWebSocketPriceMessageDecoding_malformedJSON_fails() {
        let json = "not json".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(WebSocketPriceMessage.self, from: json))
    }

    // MARK: - StockQuote

    func testStockQuote_initializerAndEquality() {
        let quote = StockQuote(
            symbol: "GOOG",
            price: 178.25,
            previousPrice: 175.00,
            description: "Alphabet Inc.",
            lastChangeDirection: .up,
            lastChangeDate: nil
        )
        XCTAssertEqual(quote.symbol, "GOOG")
        XCTAssertEqual(quote.price, 178.25)
        XCTAssertEqual(quote.previousPrice, 175.00)
        XCTAssertEqual(quote.description, "Alphabet Inc.")
        XCTAssertEqual(quote.lastChangeDirection, .up)
        XCTAssertEqual(quote.id, "GOOG")
    }

    func testStockQuote_equatable() {
        let a = StockQuote(symbol: "MSFT", price: 100, description: "Microsoft")
        let b = StockQuote(symbol: "MSFT", price: 100, description: "Microsoft")
        XCTAssertEqual(a, b)
        let c = StockQuote(symbol: "MSFT", price: 101, description: "Microsoft")
        XCTAssertNotEqual(a, c)
    }

    // MARK: - PriceFeedService

    @MainActor
    func testPriceFeedService_init_populatesQuotesFromSymbolInfo() async {
        let service = PriceFeedService()
        XCTAssertEqual(service.quotes.count, SymbolInfo.all.count)
        let aapl = service.quotes.first { $0.symbol == "AAPL" }
        XCTAssertNotNil(aapl)
        XCTAssertEqual(aapl?.description, SymbolInfo.description(for: "AAPL"))
    }

    @MainActor
    func testPriceFeedService_sortedQuotes_isDescendingByPrice() async {
        let service = PriceFeedService()
        let sorted = service.sortedQuotes
        for i in 0..<(sorted.count - 1) {
            XCTAssertGreaterThanOrEqual(sorted[i].price, sorted[i + 1].price)
        }
    }

    @MainActor
    func testPriceFeedService_injectMessage_updatesQuote() async {
        let service = PriceFeedService()
        let initialCount = service.quotes.count
        service.injectMessageForTesting(WebSocketPriceMessage(symbol: "AAPL", price: 200))
        let aapl = service.quotes.first { $0.symbol == "AAPL" }
        XCTAssertNotNil(aapl)
        XCTAssertEqual(aapl?.price, 200)
        XCTAssertNotNil(aapl?.previousPrice)
        XCTAssertNotNil(aapl?.lastChangeDirection)
        XCTAssertNotNil(aapl?.lastChangeDate)
        XCTAssertEqual(service.quotes.count, initialCount)
    }

    @MainActor
    func testPriceFeedService_injectMessage_unknownSymbol_doesNotCrash() async {
        let service = PriceFeedService()
        let countBefore = service.quotes.count
        service.injectMessageForTesting(WebSocketPriceMessage(symbol: "UNKNOWN", price: 100))
        XCTAssertEqual(service.quotes.count, countBefore)
    }

    @MainActor
    func testPriceFeedService_startFeed_setsIsFeedRunning() async {
        let service = PriceFeedService()
        XCTAssertFalse(service.isFeedRunning)
        service.startFeed()
        XCTAssertTrue(service.isFeedRunning)
        service.stopFeed()
    }

    @MainActor
    func testPriceFeedService_stopFeed_setsIsFeedRunningFalse() async {
        let service = PriceFeedService()
        service.startFeed()
        XCTAssertTrue(service.isFeedRunning)
        service.stopFeed()
        XCTAssertFalse(service.isFeedRunning)
        XCTAssertFalse(service.isConnected)
    }

    // MARK: - FeedViewModel

    @MainActor
    func testFeedViewModel_init_reflectsServiceState() async {
        let service = PriceFeedService()
        let viewModel = FeedViewModel(priceFeed: service)
        XCTAssertEqual(viewModel.sortedQuotes.count, service.quotes.count)
        XCTAssertFalse(viewModel.isFeedRunning)
        XCTAssertFalse(viewModel.isConnected)
    }

    @MainActor
    func testFeedViewModel_startFeed_updatesIsFeedRunning() async {
        let service = PriceFeedService()
        let viewModel = FeedViewModel(priceFeed: service)
        viewModel.startFeed()
        XCTAssertTrue(viewModel.isFeedRunning)
        viewModel.stopFeed()
    }

    @MainActor
    func testFeedViewModel_stopFeed_afterStart_resetsState() async {
        let service = PriceFeedService()
        let viewModel = FeedViewModel(priceFeed: service)
        viewModel.startFeed()
        viewModel.stopFeed()
        XCTAssertFalse(viewModel.isFeedRunning)
    }

    @MainActor
    func testFeedViewModel_sortedQuotes_updatesWhenServiceQuotesChange() async {
        let service = PriceFeedService()
        let viewModel = FeedViewModel(priceFeed: service)
        let initialAaplPrice = viewModel.sortedQuotes.first { $0.symbol == "AAPL" }?.price
        service.injectMessageForTesting(WebSocketPriceMessage(symbol: "AAPL", price: 999))
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s for Combine to deliver on main
        let aaplAfter = viewModel.sortedQuotes.first { $0.symbol == "AAPL" }
        XCTAssertNotNil(aaplAfter)
        XCTAssertEqual(aaplAfter?.price, 999)
        XCTAssertNotEqual(initialAaplPrice, 999)
    }

    // MARK: - SymbolDetailViewModel

    @MainActor
    func testSymbolDetailViewModel_init_withExistingSymbol_hasQuote() async {
        let service = PriceFeedService()
        let viewModel = SymbolDetailViewModel(priceFeed: service, symbol: "AAPL")
        XCTAssertEqual(viewModel.symbol, "AAPL")
        XCTAssertNotNil(viewModel.quote)
        XCTAssertEqual(viewModel.quote?.symbol, "AAPL")
    }

    @MainActor
    func testSymbolDetailViewModel_init_withUnknownSymbol_quoteNil() async {
        let service = PriceFeedService()
        let viewModel = SymbolDetailViewModel(priceFeed: service, symbol: "INVALID")
        XCTAssertEqual(viewModel.symbol, "INVALID")
        XCTAssertNil(viewModel.quote)
    }

    @MainActor
    func testSymbolDetailViewModel_quote_updatesWhenServiceReceivesMessage() async {
        let service = PriceFeedService()
        let viewModel = SymbolDetailViewModel(priceFeed: service, symbol: "AAPL")
        service.injectMessageForTesting(WebSocketPriceMessage(symbol: "AAPL", price: 999))
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s for Combine to deliver on main
        XCTAssertEqual(viewModel.quote?.price, 999)
        XCTAssertNotNil(viewModel.quote?.previousPrice)
        XCTAssertNotNil(viewModel.quote?.lastChangeDirection)
    }
}
