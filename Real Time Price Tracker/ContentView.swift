//
//  ContentView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 27/02/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var priceFeed: PriceFeedService

    var body: some View {
        NavigationStack {
            FeedView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PriceFeedService())
}
