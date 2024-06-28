//
//  MainAppView.swift
//  Leon
//
//  Created by Kevin Downey on 3/4/24.
//

import SwiftUI

struct MainAppView: View {
    @State private var symbol: String = ""
    @ObservedObject var financialViewModel: FinancialViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingFinancialDetails = false

    
    init(financialViewModel: FinancialViewModel) {
        self.financialViewModel = financialViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                symbolEntryField
                    .accessibility(identifier: "symbolEntryField")

                fetchButton
                
                // Programmatically trigger navigation to FinancialDetailView
                NavigationLink(destination: FinancialDetailView(financialViewModel: financialViewModel), isActive: $isShowingFinancialDetails) {
                        EmptyView() // This view is invisible and serves only as a navigation trigger
                    }
                
                dataDisplayScrollView
            }
            
            .navigationTitle("Stock Data")
            .toolbar {
                signOutToolbarItem
            }
            
            .onAppear {
                
                financialViewModel.loadTrendingStocks()
            }
            .background()

            
        }
        
    }
    
    // Subviews
    private var symbolEntryField: some View {
        TextField("Enter Stock Symbol", text: $symbol)
            .accessibilityIdentifier("symbolTextField") // This matches test case
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    private var fetchButton: some View {
        Button("Get Quote") {
            financialViewModel.symbol = self.symbol
            financialViewModel.fetchFinancialData(forSymbol: financialViewModel.symbol)
            isShowingFinancialDetails = true
        }
        .accessibilityIdentifier("fetchButton") // This matches test case
        .foregroundColor(.white) // Set text color to white
        .padding() // Add padding around the text
        .background(.mint) // Set background color to mint
        .cornerRadius(10) // Apply corner radius
        .shadow(radius: 5) // Add shadow
    }
    
    private var dataDisplayScrollView: some View {
        ScrollView {
            VStack(spacing: 10) {
                
                
                // Trending section
                TrendingStocksView(title: "Top Gainers", stocks: Array(financialViewModel.topGainers.prefix(2)))
                
                
                NavigationLink(destination: StocksListView(title: "Top Gainers", stocks: financialViewModel.topGainers)) {
                    Text("View All Top Gainers")
                        .foregroundColor(.mint)
                        .accessibilityIdentifier("viewAllTopGainers") 
                }
                TrendingStocksView(title: "Top Losers", stocks: Array(financialViewModel.topLosers.prefix(2)))
                
                NavigationLink(destination: StocksListView(title: "Top Losers", stocks: financialViewModel.topLosers)) {
                    Text("View All Top Losers")
                        .foregroundColor(.mint)
                }
                
            }
        }
    }
    
    private var signOutToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Sign Out", action: authViewModel.signOut)
        }
    }
}
