//
//  QuoteCard.swift
//  Leon
//
//  Created by Kevin Downey on 2/18/24.
//

import SwiftUI

struct QuoteCard: View {
    
    var quote: StockQuote

    var body: some View {
        print("Rendering QuoteCard")
    return
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.symbol)
                .accessibilityIdentifier("stockSymbolLabel") // Setting the accessibility identifier to match test case
                .font(.headline)
            HStack {
                Text("Open: \(quote.open ?? "N/A")")
                Spacer()
                Text("High: \(quote.high ?? "N/A")")
            }
            HStack {
                Text("Low: \(quote.low ?? "N/A")")
                Spacer()
                Text("Price: \(quote.price ?? "N/A")")
            }
            Text("Volume: \(quote.volume ?? "N/A")")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
        )
        .padding()
    }
}

