//
//  SymbolDetailView.swift
//  Real Time Price Tracker
//
//  Created by Rodney Pinto on 28/02/26.
//

import Foundation
import SwiftUI


// MARK: - SymbolDetailView

struct SymbolDetailView: View {
    let symbol: String

    var body: some View {
        VStack(spacing: 16) {
            Text(symbol)
                .font(.largeTitle.bold())

            Text(SymbolInfo.description(for: symbol))
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationTitle(symbol)
    }
}
