//
//  StockCardView.swift
//  Leon
//
//  Created by Kevin Downey on 3/22/24.
//

import SwiftUI

struct StockCardView: View {
    var stock: Stock
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Price: \(stock.price)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Change: \(stock.changeAmount) (\(stock.changePercentage)%)")
                    .font(.subheadline)
                    .foregroundColor(stock.changeAmount.starts(with: "-") ? .red : .green)
            }
            Spacer()
            Image(systemName: stock.changeAmount.starts(with: "-") ? "arrow.down.right" : "arrow.up.right")
                .foregroundColor(stock.changeAmount.starts(with: "-") ? .red : .green)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
