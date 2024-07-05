//
//  TrendingStocksView.swift
//  Leon
//
//  Created by Kevin Downey on 3/22/24.
//

import SwiftUI

struct TrendingStocksView: View {
    var title: String
    var stocks: [Stock]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.vertical)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(stocks) { stock in
                    StockCardView(stock: stock)
                }
            }
        }
        .padding()
    }
}
