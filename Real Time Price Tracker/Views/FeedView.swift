//
//  FeedView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import SwiftUI

// MARK: - Feed View

struct FeedView: View {
    @EnvironmentObject private var priceFeed: PriceFeedService

    var body: some View {
        List {
            ForEach(priceFeed.sortedQuotes) { quote in
                NavigationLink(value: quote.symbol) {
                    FeedRowView(quote: quote)
                }
            }
        }
        .navigationTitle("Prices")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(priceFeed.isConnected ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(priceFeed.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                        .foregroundStyle(priceFeed.isConnected ? Color.green : Color.secondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if priceFeed.isFeedRunning {
                        priceFeed.stopFeed()
                    } else {
                        priceFeed.startFeed()
                    }
                } label: {
                    Text(priceFeed.isFeedRunning ? "Stop" : "Start")
                }
            }
        }
    }
}

// MARK: - Row View

struct FeedRowView: View {
    let quote: StockQuote
    @State private var flashColor: Color?

    private var changeIndicator: (color: Color, symbol: String) {
        guard let previous = quote.previousPrice else { return (.primary, "−") }
        if quote.price > previous { return (.green, "↑") }
        if quote.price < previous { return (.red, "↓") }
        return (.primary, "−")
    }

    var body: some View {
        HStack {
            Text(quote.symbol)
                .font(.headline)

            Spacer()

            Text(formatPrice(quote.price))
                .font(.subheadline.monospacedDigit())
            Text(changeIndicator.symbol)
                .foregroundStyle(changeIndicator.color)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 4)
        .listRowBackground(flashColor ?? Color.clear)
        .onChange(of: quote.lastChangeDate) { _, _ in
            guard let direction = quote.lastChangeDirection else { return }
            switch direction {
            case .up: flashColor = Color.green.opacity(0.2)
            case .down: flashColor = Color.red.opacity(0.2)
            case .unchanged: flashColor = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                flashColor = nil
            }
        }
    }

    private func formatPrice(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}



// MARK: - Preview

#Preview {
    NavigationStack {
        FeedView()
            .environmentObject(PriceFeedService())
    }
}
