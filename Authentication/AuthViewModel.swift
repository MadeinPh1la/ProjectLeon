//
//  AuthViewModel.swift
//  Leon
//
//  Created by Kevin Downey on 2/18/24.
//

import Foundation
import Combine
import FirebaseAuth

// User Authentication
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authService: Authenticatable

    // Use dependency injection to allow for testing with mock authentication services
    init(authService: Authenticatable = FirebaseAuthService()) {
        self.authService = authService
        checkAuthState()
    }
    
    func checkAuthState() { 
        isAuthenticated = authService.isUserAuthenticated
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        authService.signIn(withEmail: email, password: password) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    // Log the full error
                    print("Sign in error: \(error)")
                    self?.errorMessage = error.localizedDescription
                } else if success {
                    self?.isAuthenticated = true
                } else {
                    self?.errorMessage = "An unknown error occurred"
                }
            }
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            isAuthenticated = false
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
            errorMessage = signOutError.localizedDescription
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        isLoading = true
        authService.createUser(withEmail: email, password: password) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Sign up error: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    self?.isAuthenticated = success
                    completion(success, nil)
                }
            }
        }
    }
}
