//
//  LeonApp.swift
//  Leon
//
//  Created by Kevin Downey on 1/18/24.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main

struct LeonApp: App {
    @StateObject private var financialViewModel = FinancialViewModel(apiService: API.shared)

    
    init() {
            FirebaseApp.configure()
        }

    // Create an instance of AuthViewModel
    @StateObject var authViewModel = AuthViewModel()


    var body: some Scene {
        WindowGroup {

            MainTabView()

            // Provide AuthViewModel as an environment object
                .environmentObject(authViewModel)
                .environmentObject(financialViewModel)


        }
    }
}
