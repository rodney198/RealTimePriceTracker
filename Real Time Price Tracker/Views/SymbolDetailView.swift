//
//  SymbolDetailView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import SwiftUI

// MARK: - SymbolDetailView

struct SymbolDetailView: View {
    @ObservedObject var viewModel: SymbolDetailViewModel
    @State private var flashColor: Color?

    private var changeIndicator: (color: Color, symbol: String) {
        guard let q = viewModel.quote, let previous = q.previousPrice else { return (.primary, "−") }
        if q.price > previous { return (.green, "↑") }
        if q.price < previous { return (.red, "↓") }
        return (.primary, "−")
    }

    var body: some View {
        Group {
            if let quote = viewModel.quote {
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
                .background(flashColor ?? Color.clear)
                .onChange(of: quote.lastChangeDate) { _, _ in
                    guard let direction = quote.lastChangeDirection else { return }
                    switch direction {
                    case .up: flashColor = Color.green.opacity(0.2)
                    case .down: flashColor = Color.red.opacity(0.2)
                    case .unchanged: flashColor = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        flashColor = nil
                    }
                }
            } else {
                Text("Symbol not found")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(viewModel.symbol)
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
        SymbolDetailView(viewModel: SymbolDetailViewModel(priceFeed: PriceFeedService(), symbol: "AAPL"))
    }
}
