//
//  ContentView.swift
//  Leon
//
//  Created by Kevin Downey on 1/18/24.
//

import SwiftUI
import SwiftData
import FirebaseAuth


// If user is authenticated, display main financial view. If user is not authenticated, display sign in view.
struct ContentView: View {
    @State private var symbol: String = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var financialViewModel = FinancialViewModel(apiService: API.shared)


    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
        //         User is authenticated, show the main app content
                MainAppView(financialViewModel: financialViewModel)
            } else {
        //         User is not authenticated, show sign-in or sign-up options
                SignInView()
            }
        }
        .id(authViewModel.isAuthenticated) // This forces SwiftUI to redraw the view when isAuthenticated changes
    }
}

// Sign In View
struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            
            Spacer()
            Image(systemName: "person.crop.circle.fill") // Consider replacing with your app logo
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 50)
            
            Spacer()

            
               if showSignUp {
                   
                   Spacer()

                   // Sign Up Form
                   TextField("Email", text: $email)
                       .autocapitalization(.none)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .disabled(authViewModel.isLoading)  // Disable input while loading
                   
                   SecureField("Password", text: $password)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .disabled(authViewModel.isLoading)  // Disable input while loading
                   
                   if authViewModel.isLoading {
                       ProgressView()
                   } else {
                       Button("Sign Up") {
                           // Call sign-up method
                           authViewModel.signUp(email: email, password: password) { success, error in
                               if success {
                                   print("Success! \(success)")

                               } else if let error = error {
                                   print("Sign up error: \(error.localizedDescription)")
                                   return
                               }
                           }
                       }
                   }
                                      
               } else {
                   // Sign In Form
                   
                   TextField("Email", text: $email)
                       .autocapitalization(.none)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .disabled(authViewModel.isLoading)  // Disable input while loading
                       .padding(.horizontal)

                   SecureField("Password", text: $password)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .disabled(authViewModel.isLoading)  // Disable input while loading
                       .padding(.horizontal)
                   
                   if authViewModel.isLoading {
                       ProgressView()
                   } else {
                       Button("Sign In") {
                           authViewModel.signIn(email: email, password: password)
                       }
                   }
               }
            
               
               // Toggle Button

            Button(showSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                   showSignUp.toggle()
               }
           }
        Spacer()

           .padding()
       }
}

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Sign Up") {
                signUpUser()
            }
            .padding()
            
        }
        .padding()
    }
    
    // Sign Up
    
    func signUpUser() {
        AuthViewModel().signUp(email: email, password: password) { success, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else if success {
                self.authViewModel.isAuthenticated = true

            }
        }
    }
}



