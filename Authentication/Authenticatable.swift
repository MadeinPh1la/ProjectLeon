//
//  Authenticatable.swift
//  Leon
//
//  Created by Kevin Downey on 3/13/24.
//

import Foundation
import FirebaseAuth
import Combine

protocol Authenticatable {
    var isUserAuthenticated: Bool { get }

    func signIn(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    func createUser(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    func signOut() throws
}

