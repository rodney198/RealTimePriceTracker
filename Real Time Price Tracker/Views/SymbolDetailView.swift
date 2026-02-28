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
        guard let q = viewModel.quote else { return (.primary, "−") }
        return PriceFormatting.changeIndicator(for: q)
    }

    var body: some View {
        Group {
            if let quote = viewModel.quote {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(PriceFormatting.formatPrice(quote.price))
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
                    case .up: flashColor = Color.green.opacity(AppConstants.Flash.backgroundOpacity)
                    case .down: flashColor = Color.red.opacity(AppConstants.Flash.backgroundOpacity)
                    case .unchanged: flashColor = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Flash.durationSeconds) {
                        flashColor = nil
                    }
                }
            } else {
                Text(AppConstants.UI.symbolNotFound)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(viewModel.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SymbolDetailView(viewModel: SymbolDetailViewModel(priceFeed: PriceFeedService(), symbol: "AAPL"))
    }
}
