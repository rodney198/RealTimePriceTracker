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
            ForEach(priceFeed.quotes) { quote in
                NavigationLink(value: quote.symbol) {
                    FeedRowView(quote: quote)
                }
            }
        }
        .navigationTitle("Prices")
        .navigationDestination(for: String.self) { symbol in
            SymbolDetailView(symbol: symbol)
        }
    }
}

// MARK: - Row View

struct FeedRowView: View {
    let quote: StockQuote

    var body: some View {
        HStack {
            Text(quote.symbol)
                .font(.headline)

            Spacer()

            Text(formatPrice(quote.price))
                .font(.subheadline.monospacedDigit())
        }
        .padding(.vertical, 4)
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
