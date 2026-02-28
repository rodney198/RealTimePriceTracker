//
//  Real_Time_Price_TrackerApp.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 27/02/26.
//

import SwiftUI

@main
struct Real_Time_Price_TrackerApp: App {
    @StateObject private var priceFeed = PriceFeedService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(priceFeed)
        }
    }
}
