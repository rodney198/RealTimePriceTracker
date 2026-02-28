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
    }
}

#Preview {
    ContentView()
        .environmentObject(PriceFeedService())
}
