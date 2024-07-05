//
//  FinancialDetailView.swift
//  Leon
//
//  Created by Kevin Downey on 3/22/24.
//

import SwiftUI

struct FinancialDetailView: View {
    @ObservedObject var financialViewModel: FinancialViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Displaying Stock Quote
                if let quote = financialViewModel.quote {
                    QuoteCard(quote: quote)
                        .accessibilityIdentifier("stockSymbolLabel")
                }
                
                // Displaying Company Overview
                if let overview = financialViewModel.companyOverview {
                    CompanyOverviewCard(overview: overview)
                }
                
                // Displaying DCF Share Price as a Card
                VStack {
                    if let dcfSharePrice = financialViewModel.dcfSharePrice {
                        Text("DCF Share Price: \(dcfSharePrice, specifier: "%.2f")")
                            .font(.bodyFont)
                            .foregroundColor(.textPrimary)
                    } else {
                        Text("DCF Share Price not available")
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Displaying Predicted Share Price
                    if let predictedPrice = financialViewModel.predictedSharePrice {
                        Text("Predicted Share Price: \(predictedPrice, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                    } else {
                        Text("Predicted Share Price not available")
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding()
                .background(Color.background)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding([.horizontal, .bottom])
                .accessibilityIdentifier("FinancialDetailView")

            }
            .navigationTitle("Financial Details")
            .onAppear {
                financialViewModel.loadDCFValue()
            }
        }
    }
}
