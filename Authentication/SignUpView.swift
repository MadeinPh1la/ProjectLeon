//
//  SignUpView.swift
//  Leon
//
//  Created by Kevin Downey on 2/12/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // Access AuthViewModel from the environment
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if authViewModel.isLoading {
                ProgressView()
            } else {
                Button("Sign Up") {
                    signUpUser()
                }
                .padding()
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    func signUpUser() {
           authViewModel.signUp(email: email, password: password) { success, error in
               DispatchQueue.main.async {
                   if success {
                       // Update UI for successful sign-up
                   } else {
                       // Show error message
                   }
               }
           }
       }
}
