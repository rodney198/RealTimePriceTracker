//
//  FeedView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import SwiftUI


// MARK: - Model

struct StaticQuote: Identifiable {
    let id = UUID()
    let symbol: String
    let price: Decimal
}

// MARK: - Feed View

struct FeedView: View {

    private let quotes = SymbolInfo.staticQuotes

    var body: some View {
        List {
            ForEach(quotes) { quote in
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
    let quote: StaticQuote

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
    }
}
