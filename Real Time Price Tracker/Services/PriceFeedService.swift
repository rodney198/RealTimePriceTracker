//
//  PriceFeedService.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import Foundation

struct WebSocketPriceMessage: Codable {
    let symbol: String
    let price: Double
}

//MARK: -Forwards URLSessionWebSocketDelegate callbacks to the service
private final class WebSocketDelegate: NSObject, URLSessionWebSocketDelegate, URLSessionDelegate {
    weak var service: PriceFeedService?

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocolName: String?) {
        Task { @MainActor in
            service?.webSocketDidOpen()
        }
    }
}

@MainActor
final class PriceFeedService: ObservableObject {
    @Published private(set) var quotes: [StockQuote] = []
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var isFeedRunning: Bool = false

    var sortedQuotes: [StockQuote] {
        quotes.sorted { $0.price > $1.price }
    }

    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    private let webSocketDelegate = WebSocketDelegate()
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    private let urlSession: URLSession
    private let priceVariationPercent: Double = 0.02

    init() {
        quotes = SymbolInfo.all.map { item in
            StockQuote(
                symbol: item.symbol,
                price: SymbolInfo.initialPrice(for: item.symbol),
                previousPrice: nil,
                description: item.description
            )
        }
        urlSession = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: .main)
        webSocketDelegate.service = self
    }

    //MARK: -Called by WebSocketDelegate when the WebSocket handshake completes.
    func webSocketDidOpen() {
        guard isFeedRunning else { return }
        isConnected = true
        print("[PriceFeed] WebSocket connected")
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                debugPrint("Send Price Updates")
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func startFeed() {
        guard !isFeedRunning else { return }
        print("[PriceFeed] starting feed...")
        isFeedRunning = true
        connect()
    }

    func stopFeed() {
        print("[PriceFeed] stopping feed")
        timer?.invalidate()
        timer = nil
        isFeedRunning = false
        disconnect()
    }

    private func connect() {
        guard webSocketTask == nil else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        print("[PriceFeed] connecting to WebSocket...")

    }

    private func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    //MARK: -Call when connection is lost so reconnection works on next Start.
    private func connectionLost() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

}
