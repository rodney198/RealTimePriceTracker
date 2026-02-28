//
//  ContentView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 27/02/26.
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var resolved: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

struct ContentView: View {
    @EnvironmentObject private var priceFeed: PriceFeedService
    @EnvironmentObject private var feedViewModel: FeedViewModel
    @State private var navigationPath = NavigationPath()
    @AppStorage("preferredColorScheme") private var preferredThemeRaw: String = AppTheme.system.rawValue

    private var resolvedScheme: ColorScheme? {
        AppTheme(rawValue: preferredThemeRaw)?.resolved
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            FeedView(preferredThemeRaw: $preferredThemeRaw)
                .navigationDestination(for: String.self) { symbol in
                    SymbolDetailView(viewModel: SymbolDetailViewModel(priceFeed: priceFeed, symbol: symbol))
                }
        }
        .preferredColorScheme(resolvedScheme)
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
    ContentViewPreview.content
}

@MainActor
private enum ContentViewPreview {
    static var content: some View {
        let priceFeed = PriceFeedService()
        return ContentView()
            .environmentObject(priceFeed)
            .environmentObject(FeedViewModel(priceFeed: priceFeed))
    }
}
