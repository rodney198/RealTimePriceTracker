//
//  FeedView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import SwiftUI

// MARK: - Feed View

struct FeedView: View {
    @EnvironmentObject private var viewModel: FeedViewModel
    @Binding var preferredThemeRaw: String

    var body: some View {
        List {
            ForEach(viewModel.sortedQuotes) { quote in
                NavigationLink(value: quote.symbol) {
                    FeedRowView(quote: quote)
                }
            }
        }
        .navigationTitle(AppConstants.UI.feedTitle)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(viewModel.isConnected ? AppConstants.UI.connected : AppConstants.UI.disconnected)
                        .font(.caption)
                        .foregroundStyle(viewModel.isConnected ? Color.green : Color.secondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Picker(AppConstants.UI.themePickerTitle, selection: $preferredThemeRaw) {
                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Text(theme.displayName).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    Button {
                        if viewModel.isFeedRunning {
                            viewModel.stopFeed()
                        } else {
                            viewModel.startFeed()
                        }
                    } label: {
                        Text(viewModel.isFeedRunning ? AppConstants.UI.stop : AppConstants.UI.start)
                    }
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
        PriceFormatting.changeIndicator(for: quote)
    }

    var body: some View {
        HStack {
            Text(quote.symbol)
                .font(.headline)

            Spacer()

            Text(PriceFormatting.formatPrice(quote.price))
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
            case .up: flashColor = Color.green.opacity(AppConstants.Flash.backgroundOpacity)
            case .down: flashColor = Color.red.opacity(AppConstants.Flash.backgroundOpacity)
            case .unchanged: flashColor = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Flash.durationSeconds) {
                flashColor = nil
            }
        }
    }
}



// MARK: - Preview

#Preview {
    NavigationStack {
        FeedView(preferredThemeRaw: .constant(AppTheme.system.rawValue))
            .environmentObject(FeedViewModel(priceFeed: PriceFeedService()))
    }
}
