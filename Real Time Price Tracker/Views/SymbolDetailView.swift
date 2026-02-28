//
//  SymbolDetailView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import SwiftUI

// MARK: - SymbolDetailView

struct SymbolDetailView: View {
    let symbol: String
    @EnvironmentObject private var priceFeed: PriceFeedService

    private var quote: StockQuote? {
        priceFeed.quotes.first { $0.symbol == symbol }
    }

    private var changeIndicator: (color: Color, symbol: String) {
        guard let q = quote, let previous = q.previousPrice else { return (.primary, "−") }
        if q.price > previous { return (.green, "↑") }
        if q.price < previous { return (.red, "↓") }
        return (.primary, "−")
    }

    var body: some View {
        Group {
            if let quote = quote {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(formatPrice(quote.price))
                            .font(.largeTitle.monospacedDigit())
                        Text(changeIndicator.symbol)
                            .foregroundStyle(changeIndicator.color)
                            .font(.title2.weight(.semibold))
                    }
                    Text(quote.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            } else {
                Text("Symbol not found")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatPrice(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}

#Preview {
    NavigationStack {
        SymbolDetailView(symbol: "AAPL")
            .environmentObject(PriceFeedService())
    }
}
