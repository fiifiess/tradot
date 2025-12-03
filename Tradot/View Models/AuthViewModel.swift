//
//  AuthViewModel.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import Foundation
import FirebaseAuth



@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var role: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String = ""
    
    @Published var currentUserID: String? = nil
    
    weak var appViewModel: AppViewModel?
    let authService = AuthService()
    let profileService = ProfileService.shared

    init(appViewModel: AppViewModel? = nil) {
        self.appViewModel = appViewModel
        updateCurrentUserId()
    }
    
    func logIn() async {
        //Implement FirebaseAuth sign-in
        isLoading = true
        do{
            let user = try await authService.login(email: email, password: password)
            print("AuthViewModel.logIn(): sign-in succeeded, firebase uid = \(user.id)")
            // call handleLogin on appViewModel (which will now do the reset + fetch + listen)
            appViewModel?.handleLogin(user: user)
            updateCurrentUserId()
            print("AuthViewModel.logIn(): appViewModel.handleLogin called. currentUserID = \(String(describing: currentUserID))")
            errorMessage = ""
            successMessage = ""
            if let uID = currentUserId(){
                print("This is the user ID: \(uID)")
            }
        } catch {
            print("AuthViewModel.logIn(): sign-in FAILED: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            successMessage = ""
        }
        
        isLoading = false
        
    }
    
    func signUp() async {
        //Implement FirebaseAuth = Firestore sign-up
        isLoading = true
        do {
            let user = try await authService.signUp(name: name, email: email, password: password)
            
            // 27-11
            print("Creating profile for userID: \(user.id)")

            do {
                try await ProfileService.shared.createProfile(userID: user.id, name: name, email: email)
                print("Profile successfully created.")
            } catch {
                print("🔥 createProfile FAILED: \(error)")
                throw error
            }
            
            print("Fetching profile for userID: \(user.id)")
            do {
                _ = try await ProfileService.shared.fetchProfile(uid: user.id, ignoreCache: true)
            } catch {
                print("🔥 fetchProfile FAILED: \(error)")
                throw error
            }
            
            // 27-11
            
            appViewModel?.handleLogin(user: user)
            updateCurrentUserId()
            errorMessage = ""
            successMessage = ""
        } catch {
            errorMessage = error.localizedDescription
            successMessage = ""
        }
        isLoading = false
    }
    
    func logOut() {
        do {
            try authService.logOut()
            appViewModel?.handleLogout()
            currentUserID = nil
        } catch {
            errorMessage = error.localizedDescription
        }

    }
    
    func sendPasswordReset(to email: String) async {
            isLoading = true
            errorMessage = ""
            successMessage = ""
            do {
                try await authService.sendPasswordReset(to: email)
                successMessage = "Password reset email sent to \(email)."
                errorMessage = ""
                profileService.resetProfileState()
            } catch {
                successMessage = ""
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    
    func checkAuthStatus() {
        if let user = authService.currentUser() {
            appViewModel?.handleLogin(user: user)
            updateCurrentUserId()  // Keep ID in sync
        } else {
            appViewModel?.handleLogout()
            currentUserID = nil
        }
    }
    
    func currentUserId() -> String? {
        return authService.currentUser()?.id
    }
    
    private func updateCurrentUserId() {
        currentUserID = authService.currentUser()?.id
    }
    
    func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection and try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "No user found with this email. Please sign up first."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address. Please check and try again."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered. Try logging in instead."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak. Please use a stronger password."
        default:
            return nsError.localizedDescription
        }
    }
    
    // Helper to get current user ID safely
        func currentUserIdSafe() -> String? {
            return authService.currentUser()?.id
        }
}
