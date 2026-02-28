//
//  AppConstants.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import Foundation

enum AppConstants {

    enum DeepLink {
        static let scheme = "stocks"
        static let host = "symbol"
    }

    enum Theme {
        static let preferredColorSchemeStorageKey = "preferredColorScheme"
    }

    enum UI {
        static let feedTitle = "Prices"
        static let connected = "Connected"
        static let disconnected = "Disconnected"
        static let stop = "Stop"
        static let start = "Start"
        static let themePickerTitle = "Theme"
        static let symbolNotFound = "Symbol not found"
    }

    enum Flash {
        static let durationSeconds: TimeInterval = 1.0
        static let backgroundOpacity: Double = 0.2
    }

    enum PriceFeed {
        static let webSocketURLString = "wss://ws.postman-echo.com/raw"
        static let priceVariationPercent: Double = 0.02
        static let timerInterval: TimeInterval = 2.0
        static let requestTimeout: TimeInterval = 10
    }
}
