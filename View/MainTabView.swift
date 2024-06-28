//
//  MainTabView.swift
//  Leon
//
//  Created by Kevin Downey on 3/21/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var financialViewModel = FinancialViewModel(apiService: API.shared)
    @EnvironmentObject var authViewModel: AuthViewModel

    let symbol = "AAPL"

    var body: some View {
        TabView {
            MainAppView(financialViewModel: financialViewModel)
                .tabItem {
                    Label("Financial", systemImage: "dollarsign.circle")
                        .accessibilityIdentifier("FinancialTab")

                }

            NewsFeedView(symbol: symbol)
                .tabItem {
                    Label("News", systemImage: "newspaper")
                        .accessibilityIdentifier("NewsTab")

                }
        }
    }
}
