//
//  AuthService.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import Foundation
import FirebaseAuth

enum AuthError: Error {
    case invalidCredentials
    case networkError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError(let msg):
            return msg
        case .unknown:
            return "An unknown error occured"
        }
    }
}

class AuthService {
    
    func login(email: String, password: String) async throws -> User {
        
        try await withCheckedThrowingContinuation{ continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: AuthError.networkError(error.localizedDescription))
                    return
                }
                guard let firebaseUser = result?.user else {
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }
                let user = User(id: firebaseUser.uid, name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "", role: .client)
                continuation.resume(returning: user)
            }
        }
        
        
        
    }
    
    func signUp(name: String, email: String, password: String) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: AuthError.networkError(error.localizedDescription))
                    return
                }
                guard let firebaseUser = result?.user else {
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }
                let changeRequest = firebaseUser.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { commitError in
                    if commitError != nil {
                        // profile update failed but account exists - still return user
                        let user = User(id: firebaseUser.uid, name: name, email: firebaseUser.email ?? "", role: .client )
                        continuation.resume(returning: user)
                        return
                    }
                    let user = User(id: firebaseUser.uid, name: name, email: firebaseUser.email ?? "", role: .client)
                    continuation.resume(returning: user)
                }
            }
        }
    }
    
    func sendPasswordReset(to email: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    continuation.resume(throwing: AuthError.networkError(error.localizedDescription))
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func logOut() throws {
        do{
            try Auth.auth().signOut()
        } catch{
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    func currentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else {
            return nil
        }
        return User(id: firebaseUser.uid, name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "", role: .client)
    }
    
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    

}
