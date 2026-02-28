//
//  PriceFeedService.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import Foundation
import Combine

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
    private let url = URL(string: "wss://ws.postman-echo.com/raw")
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
        debugPrint("[PriceFeed] WebSocket connected")
        let t = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                debugPrint("Send Price Updates")
                self?.sendPriceUpdates()
            }
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
    }

    func startFeed() {
        guard !isFeedRunning else { return }
        debugPrint("[PriceFeed] starting feed...")
        isFeedRunning = true
        connect()
    }

    func stopFeed() {
        debugPrint("[PriceFeed] stopping feed")
        timer?.invalidate()
        timer = nil
        isFeedRunning = false
        disconnect()
    }

    private func connect() {
        guard webSocketTask == nil else { return }
        guard let url = url else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        debugPrint("[PriceFeed] connecting to WebSocket...")
        receiveMessage()
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

    private func sendPriceUpdates() {
        guard let task = webSocketTask, isConnected else { return }
        let symbolsAndPrices: [(String, Double)] = quotes.indices.map { index in
            let currentPrice = NSDecimalNumber(decimal: quotes[index].price).doubleValue
            let delta = currentPrice * priceVariationPercent * (Double.random(in: -1...1))
            let newPrice = max(0.01, currentPrice + delta)
            return (quotes[index].symbol, newPrice)
        }
        debugPrint("[PriceFeed] sending \(symbolsAndPrices.count) price updates")
        for (symbol, newPrice) in symbolsAndPrices {
            let message = WebSocketPriceMessage(symbol: symbol, price: newPrice)
            guard let data = try? JSONEncoder().encode(message),
                  let jsonString = String(data: data, encoding: .utf8) else { continue }
            task.send(.string(jsonString)) { [weak self] error in
                if error != nil {
                    Task { @MainActor in
                        self?.connectionLost()
                    }
                }
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleReceivedData(data)
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        self?.handleReceivedData(data)
                    }
                @unknown default:
                    break
                }
            case .failure:
                Task { @MainActor in
                    self?.connectionLost()
                }
            }
            Task { @MainActor [weak self] in
                guard let self = self, self.webSocketTask != nil, self.isFeedRunning else { return }
                self.receiveMessage()
            }
        }
    }

    private nonisolated func handleReceivedData(_ data: Data) {
        guard let decoded = try? JSONDecoder().decode(WebSocketPriceMessage.self, from: data) else { return }
        let symbol = decoded.symbol
        let newPrice = Decimal(decoded.price)
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            guard let index = self.quotes.firstIndex(where: { $0.symbol == symbol }) else { return }
            var quote = self.quotes[index]
            let previousPrice = quote.price
            let direction: PriceChangeDirection = newPrice > previousPrice ? .up : (newPrice < previousPrice ? .down : .unchanged)
            quote.previousPrice = previousPrice
            quote.price = newPrice
            quote.lastChangeDirection = direction
            quote.lastChangeDate = Date()
            var updated = self.quotes
            updated[index] = quote
            self.quotes = updated
            debugPrint("[PriceFeed] value changed: \(symbol) \(previousPrice) → \(newPrice)")
        }
    }
}
