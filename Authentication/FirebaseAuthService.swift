//
//  FirebaseAuthService.swift
//  Leon
//
//  Created by Kevin Downey on 3/13/24.
//

import FirebaseAuth

class FirebaseAuthService: Authenticatable {
    
    var isUserAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            completion(authResult != nil, error)
        }
    }

    func createUser(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            completion(authResult != nil, error)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
