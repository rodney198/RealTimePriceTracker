# Real Time Price Tracker

A SwiftUI iOS app that displays real-time stock quotes. Prices are streamed over a WebSocket, and the feed can be started or stopped from the UI. Tapping a symbol opens a detail screen with live price and change indicator; the app also supports deep linking to open a symbol by URL.

---

## Features

- **Live price feed** — WebSocket-based stream of quote updates; optional Start/Stop control.
- **Symbol list** — Sorted by price (highest first) with up/down/unchanged indicators and row flash on change.
- **Symbol detail** — Live price, change arrow, and company description for each symbol.
- **Deep linking** — Open a symbol directly via `stocks://symbol/<SYMBOL>` (e.g. `stocks://symbol/AAPL`).
- **Connection status** — Toolbar shows Connected (green) or Disconnected (red) with a status dot.

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
│   ├── Real_Time_Price_TrackerApp.swift   # App entry; creates PriceFeedService, injects into environment
│   ├── ContentView.swift                  # Root: NavigationStack(path), navigationDestination, onOpenURL
│   ├── Models/
│   │   ├── StockQuote.swift               # Quote model, PriceChangeDirection
│   │   └── SymbolInfo.swift               # Static symbol list + descriptions + initial prices
│   ├── Services/
│   │   └── PriceFeedService.swift         # WebSocket client, quote updates, Start/Stop
│   └── Views/
│       ├── FeedView.swift                 # List of quotes, toolbar (status + Start/Stop)
│       └── SymbolDetailView.swift        # Live price, change indicator, description
├── Real Time Price TrackerTests/
├── Real Time Price TrackerUITests/
└── README.md
```

---

## Architecture

- **App** — Owns a single `PriceFeedService` instance and passes it down via `.environmentObject(priceFeed)`.
- **ContentView** — Holds `NavigationPath`, hosts `NavigationStack(path:)` and `.navigationDestination(for: String.self)` so pushing a symbol (from the list or from a deep link) shows `SymbolDetailView`. Handles `onOpenURL` for `stocks://symbol/...`.
- **FeedView** — Reads `priceFeed` from the environment, shows sorted quotes and toolbar; navigation is driven by `NavigationLink(value: quote.symbol)`.
- **SymbolDetailView** — Gets `priceFeed` from the environment, looks up the quote by symbol, and shows live price, change indicator, and description (or “Symbol not found”).
- **PriceFeedService** — Connects to `wss://ws.postman-echo.com/raw`, sends simulated price updates, receives and decodes `WebSocketPriceMessage`, and updates `quotes` on the main actor.

---

## How it works

### Shared price feed

The app creates a single `PriceFeedService` in the entry point (`Real_Time_Price_TrackerApp`) and injects it into the view hierarchy with `.environmentObject(priceFeed)`. That way the feed is one shared instance: the list and the detail screen both read from the same `quotes` and connection state. No view owns or creates the service; they all receive it from the environment.

### Path-based navigation

The root view (`ContentView`) holds a `NavigationPath` and uses `NavigationStack(path: $navigationPath)`. The destination for a symbol string is registered once in the root with `.navigationDestination(for: String.self) { symbol in SymbolDetailView(symbol: symbol) }`. When the user taps a row in the feed, `NavigationLink(value: quote.symbol)` pushes that symbol onto the path and the stack shows the detail screen. Because the path is owned at the root, the app can also push a symbol programmatically—for example when handling a link.

### Deep linking

When the app is opened with a URL like `stocks://symbol/AAPL`, `ContentView` handles it in `.onOpenURL`. It checks that the scheme is `stocks` and the host is `symbol`, then takes the path (e.g. `AAPL`), trims slashes, and appends it to `navigationPath`. That push causes the same symbol detail screen to appear as if the user had tapped the symbol in the list. For this to work, the app must declare the `stocks` URL scheme in Xcode (Target → Info → URL Types).

### Live symbol detail

The symbol detail screen receives `PriceFeedService` from the environment. It looks up the current quote with `priceFeed.quotes.first { $0.symbol == symbol }` and displays the live price, a change indicator (up/down/unchanged with color and arrow), and the quote’s description. If there is no quote for that symbol (e.g. an unknown symbol from a link), it shows “Symbol not found”. The layout uses a leading-aligned stack with the price and arrow in a row, then the description below.

### Feed list UI

The feed list shows quotes sorted by price (highest first). Each row shows symbol, price, and a change arrow; when a price updates, the row briefly flashes green or red. The toolbar has a status dot (green when connected, red when disconnected) with “Connected”/“Disconnected” text, and a Start/Stop button that calls `priceFeed.startFeed()` or `priceFeed.stopFeed()`. The feed does not auto-start on launch; the user taps Start to begin receiving updates.

---

## How to run

1. Open `Real Time Price Tracker.xcodeproj` in Xcode.
2. Select a simulator or device and run (⌘R).
3. Use **Start** in the feed toolbar to begin receiving price updates.
4. Tap a symbol to open its detail; use the back button to return.

---

## Deep linking

- **URL format:** `stocks://symbol/<SYMBOL>` (e.g. `stocks://symbol/AAPL`, `stocks://symbol/TSLA`).
- **Setup:** In Xcode, add a URL Type with scheme `stocks` (Target → Info → URL Types).
- **Testing:** In the Simulator, use **File → Open URL…** and enter `stocks://symbol/AAPL`.

---

## License

Private / project-specific. See repository or team for terms.
