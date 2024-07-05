//
//  StocksListView.swift
//  Leon
//
//  Created by Kevin Downey on 3/22/24.
//

import SwiftUI

struct StocksListView: View {
    var title: String
    var stocks: [Stock]

    // Limit the stocks displayed to 10
    var limitedStocks: [Stock] {
        Array(stocks.prefix(10))
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(limitedStocks) { stock in
                    VStack(alignment: .leading) {
                        Text(stock.ticker)
                            .font(.headline)
                            .accessibility(identifier: "ticker_\(stock.ticker)")
                        Text("Price: \(stock.price)")
                        Text("Change: \(stock.changeAmount) (\(stock.changePercentage)%)")
                            .foregroundColor(stock.changeAmount.starts(with: "-") ? .red : .green)
                    }
                    .padding()
                    Divider() 
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .accessibility(identifier: "stocksListView")
    }
}
