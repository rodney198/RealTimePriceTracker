# Real Time Price Tracker

A SwiftUI iOS app that displays real-time stock quotes. Prices are streamed over a WebSocket (handled with Combine), and the feed can be started or stopped from the UI. The app uses MVVM: views bind to ViewModels that wrap a shared `PriceFeedService`. Tapping a symbol opens a detail screen with live price and change indicator; price changes flash green (up) or red (down) for 1 second. Light/dark theme can be toggled in the feed toolbar, and the app supports deep linking to open a symbol by URL.

---

## Features

- **Live price feed** — WebSocket-based stream of quote updates via Combine; optional Start/Stop control.
- **Symbol list** — Sorted by price (highest first) with up/down/unchanged indicators and row flash on change.
- **Symbol detail** — Live price, change arrow, and company description; detail price also flashes on change.
- **MVVM** — `FeedViewModel` and `SymbolDetailViewModel` expose state and actions; views observe ViewModels, not the service directly.
- **Light/dark theme** — Toolbar picker for System / Light / Dark; choice persisted with `AppStorage`.
- **Deep linking** — Open a symbol directly via `stocks://symbol/<SYMBOL>` (e.g. `stocks://symbol/AAPL`).
- **Connection status** — Toolbar shows Connected (green) or Disconnected (red) with a status dot.
- **Shared code** — Constants in `Support/AppConstants.swift`; price formatting and change-indicator logic in `Support/PriceFormatting.swift`.
- **Tests** — Unit tests (models, WebSocket message decoding, PriceFeedService, ViewModels) and UI tests (feed and symbol detail).

---

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

---

## Project structure

```
Real Time Price Tracker/
├── Real Time Price Tracker/
│   ├── Real_Time_Price_TrackerApp.swift   # App entry; AppState owns PriceFeedService + FeedViewModel
│   ├── ContentView.swift                  # Root: NavigationStack(path), theme, onOpenURL, navigationDestination
│   ├── Models/
│   │   ├── StockQuote.swift               # Quote model, PriceChangeDirection
│   │   └── SymbolInfo.swift               # Static symbol list + descriptions + initial prices
│   ├── Services/
│   │   └── PriceFeedService.swift         # WebSocket client, Combine message stream, quote updates
│   ├── ViewModels/
│   │   ├── FeedViewModel.swift            # Exposes sortedQuotes, connection state, start/stop
│   │   └── SymbolDetailViewModel.swift    # Exposes quote for a symbol; observes service
│   ├── Support/
│   │   ├── AppConstants.swift             # Deep link, theme, UI strings, flash, PriceFeed config
│   │   └── PriceFormatting.swift          # formatPrice(_:), changeIndicator(for:)
│   └── Views/
│       ├── FeedView.swift                 # List (FeedRowView), toolbar (status, theme picker, Start/Stop)
│       └── SymbolDetailView.swift         # Live price, change indicator, description
├── Real Time Price TrackerTests/          # Unit tests (models, service, ViewModels)
├── Real Time Price TrackerUITests/        # UI tests (feed, symbol detail)
├── Info.plist                             # URL scheme "stocks" for deep linking (project root)
└── README.md
```

---

## Architecture

- **App** — Creates a single `AppState` (which owns one `PriceFeedService` and one `FeedViewModel`) and injects `priceFeed` and `feedViewModel` via `.environmentObject`.
- **ContentView** — Holds `NavigationPath` and preferred theme (`@AppStorage`). Hosts `NavigationStack(path:)` with root `FeedView` and `.navigationDestination(for: String.self)` that builds `SymbolDetailView(viewModel: SymbolDetailViewModel(priceFeed:, symbol:))`. Applies `.preferredColorScheme(resolvedScheme)` and handles `onOpenURL` using `AppConstants.DeepLink` (scheme `stocks`, host `symbol`).
- **FeedView** — Uses `@EnvironmentObject viewModel: FeedViewModel` and a `@Binding` for theme; shows sorted quotes and toolbar (connection status, theme picker, Start/Stop). Rows use `PriceFormatting.formatPrice` and `PriceFormatting.changeIndicator`; flash uses `AppConstants.Flash`.
- **SymbolDetailView** — Takes `@ObservedObject viewModel: SymbolDetailViewModel`; shows live price, change indicator, description (or `AppConstants.UI.symbolNotFound`). Same formatting and flash helpers.
- **FeedViewModel** — Observes `PriceFeedService` via Combine; exposes `sortedQuotes`, `isConnected`, `isFeedRunning` and forwards `startFeed()` / `stopFeed()`.
- **SymbolDetailViewModel** — Takes `PriceFeedService` and symbol; subscribes to `priceFeed.$quotes` and exposes `quote` for that symbol.
- **PriceFeedService** — Connects to WebSocket URL from `AppConstants.PriceFeed`, uses a `PassthroughSubject` for decoded messages and a `.sink` to update `quotes`; exposes `startFeed()` / `stopFeed()`. Single connection shared by all screens.

---

## How it works

### Shared price feed and ViewModels

The app creates one `PriceFeedService` and one `FeedViewModel` in `AppState` and injects both into the environment. The feed list and symbol detail screen both observe the same service (via ViewModels), so there is a single WebSocket connection and no duplicate state.

### Path-based navigation

`ContentView` holds a `NavigationPath` and registers `.navigationDestination(for: String.self)` so that pushing a symbol string shows the detail screen. Tapping a row uses `NavigationLink(value: quote.symbol)`. The same path is used when handling a deep link: `onOpenURL` appends the symbol to `navigationPath`.

### Deep linking

When opened with a URL like `stocks://symbol/AAPL`, `ContentView` uses `AppConstants.DeepLink.scheme` and `AppConstants.DeepLink.host` to validate the URL, then trims the path and appends it to `navigationPath`. The app declares the `stocks` URL scheme via `Info.plist` at the project root (or Target → Info → URL Types).

### Theme

The preferred appearance (System / Light / Dark) is stored with `@AppStorage(AppConstants.Theme.preferredColorSchemeStorageKey)` and applied with `.preferredColorScheme(resolvedScheme)` on the root view. The feed toolbar includes a theme picker.

### Constants and helpers

- **AppConstants** — Deep link scheme/host, theme storage key, UI strings (titles, labels), flash duration/opacity, and PriceFeed URL/timer/timeout/variation.
- **PriceFormatting** — `formatPrice(_:)` for decimal display and `changeIndicator(for:)` for (color, symbol) so feed and detail stay consistent.

---

## How to run

1. Open `Real Time Price Tracker.xcodeproj` in Xcode.
2. Select a simulator or device and run (⌘R).
3. Use **Start** in the feed toolbar to begin receiving price updates.
4. Tap a symbol to open its detail; use the back button to return.
5. Use the theme menu in the toolbar to switch System / Light / Dark.

---

## Testing

- **Unit tests** — In Xcode: Test navigator (⌘6) or **Product → Test** (⌘U). Covers `WebSocketPriceMessage` decoding, `StockQuote`, `PriceFeedService` (init, sortedQuotes, injectMessage, start/stop), `FeedViewModel`, and `SymbolDetailViewModel`.
---

## Deep linking

- **URL format:** `stocks://symbol/<SYMBOL>` (e.g. `stocks://symbol/AAPL`, `stocks://symbol/TSLA`).
- **Setup:** The project uses `Info.plist` at the repo root with `CFBundleURLTypes` / scheme `stocks`; the app target has `INFOPLIST_FILE = Info.plist` so the scheme is merged.
- **Testing:** In the Simulator, use **File → Open URL…** and enter `stocks://symbol/AAPL`.

---
