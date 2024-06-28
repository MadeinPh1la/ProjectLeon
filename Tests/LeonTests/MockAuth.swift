//
//  MockAuth.swift
//  LeonTests
//
//  Created by Kevin Downey on 3/13/24.
//

@testable import Leon
import Foundation
//import FirebaseAuth

// Mock implementation of Authenticatable for testing AuthViewModel
class MockAuth: Authenticatable {
    var shouldAuthenticateSuccessfully = true
       var isUserAuthenticated: Bool {
           return shouldAuthenticateSuccessfully
       }
    
    // Simulate sign in
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        if shouldAuthenticateSuccessfully {
            completion(true, nil)
        } else {
            completion(false, NSError(domain: "Test", code: -1, userInfo: nil))
        }
    }
    
    // Simulate sign out

    func signOut() throws {
    }

    
    // Simulate create user if needed
    
    func createUser(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        if shouldAuthenticateSuccessfully {
            completion(true, nil)
        } else {
            completion(false, NSError(domain: "Test", code: -1, userInfo: nil))
        }
    }
}
