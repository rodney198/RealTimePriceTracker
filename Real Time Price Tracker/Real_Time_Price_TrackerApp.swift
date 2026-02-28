//
//  Real_Time_Price_TrackerApp.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 27/02/26.
//

import SwiftUI

@main
struct Real_Time_Price_TrackerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState.priceFeed)
                .environmentObject(appState.feedViewModel)
        }
    }
}

@MainActor
private final class AppState: ObservableObject {
    let priceFeed: PriceFeedService
    let feedViewModel: FeedViewModel

    init() {
        let priceFeed = PriceFeedService()
        self.priceFeed = priceFeed
        self.feedViewModel = FeedViewModel(priceFeed: priceFeed)
    }
}
