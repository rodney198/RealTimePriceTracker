//
//  ContentView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 27/02/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var priceFeed: PriceFeedService
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            FeedView()
                .navigationDestination(for: String.self) { symbol in
                    SymbolDetailView(symbol: symbol)
                }
        }
        .onAppear { priceFeed.startFeed() }
        .onOpenURL { url in
            guard url.scheme == "stocks", url.host == "symbol" else { return }
            let symbol = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !symbol.isEmpty {
                navigationPath.append(symbol)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PriceFeedService())
}
