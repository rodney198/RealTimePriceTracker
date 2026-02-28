//
//  SymbolInfo.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 27/02/26.
//

import Foundation

enum SymbolInfo {
    static let all: [(symbol: String, description: String)] = [
        ("AAPL", "Apple Inc. – Technology company providing consumer electronics, software, and services."),
        ("GOOG", "Alphabet Inc. – Parent company of Google, offering search, advertising, and cloud services."),
        ("GOOGL", "Alphabet Inc. Class A – Same as GOOG with different share class."),
        ("MSFT", "Microsoft Corporation – Technology company known for Windows, Office, Azure, and Xbox."),
        ("AMZN", "Amazon.com Inc. – E-commerce and cloud computing company (AWS)."),
        ("NVDA", "NVIDIA Corporation – Designs GPUs for gaming, professional, and data center markets."),
        ("META", "Meta Platforms Inc. – Social media and technology company (Facebook, Instagram, WhatsApp)."),
        ("TSLA", "Tesla Inc. – Electric vehicle and clean energy company."),
        ("BRK.B", "Berkshire Hathaway Class B – Conglomerate holding company led by Warren Buffett."),
        ("UNH", "UnitedHealth Group – Health insurance and health care services."),
        ("JNJ", "Johnson & Johnson – Pharmaceutical and consumer health products."),
        ("JPM", "JPMorgan Chase – Major investment bank and financial services."),
        ("V", "Visa Inc. – Global payments technology company."),
        ("PG", "Procter & Gamble – Consumer goods company (household and personal care)."),
        ("XOM", "Exxon Mobil – Oil and gas corporation."),
        ("HD", "The Home Depot – Home improvement retail chain."),
        ("MA", "Mastercard – Global payments and technology company."),
        ("CVX", "Chevron Corporation – Oil and gas company."),
        ("ABBV", "AbbVie Inc. – Biopharmaceutical company."),
        ("MRK", "Merck & Co. – Pharmaceutical company."),
        ("PEP", "PepsiCo – Food and beverage corporation."),
        ("KO", "The Coca-Cola Company – Beverage corporation."),
        ("COST", "Costco Wholesale – Membership retail chain."),
        ("AVGO", "Broadcom Inc. – Semiconductor and infrastructure software."),
        ("WMT", "Walmart Inc. – Multinational retail corporation.")
    ]

    static func description(for symbol: String) -> String {
        all.first { $0.symbol == symbol }?.description ?? "No description available."
    }

    static func initialPrice(for symbol: String) -> Decimal {
        let basePrices: [String: Double] = [
            "AAPL": 182, "GOOG": 178, "GOOGL": 177, "MSFT": 415, "AMZN": 198,
            "NVDA": 142, "META": 585, "TSLA": 248, "BRK.B": 410, "UNH": 525,
            "JNJ": 158, "JPM": 198, "V": 278, "PG": 168, "XOM": 118,
            "HD": 395, "MA": 475, "CVX": 155, "ABBV": 178, "MRK": 128,
            "PEP": 168, "KO": 58, "COST": 845, "AVGO": 218, "WMT": 68
        ]
        return Decimal(basePrices[symbol] ?? 100)
    }
}
