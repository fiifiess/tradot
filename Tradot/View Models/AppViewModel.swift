//
//  AppView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 21/10/2025.
//

import Foundation

@MainActor
class AppViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false
        
    @Published var authViewModel = AuthViewModel()
    @Published var profileViewModel: ProfileViewModel? = nil

    
    init() {
        authViewModel.appViewModel = self
        //self.authViewModel.appViewModel = self
        
        self.authViewModel.checkAuthStatus()
    }
    
    func handleLogin(user: User) {
        
        print("AppViewModel.handleLogin() called with user.id = \(user.id)")
        
        // Clear any previous profile state before creating new ProfileViewModel
        print("AppViewModel: resetting ProfileService state before creating ProfileViewModel")
        ProfileService.shared.resetProfileState()
        
        self.currentUser = user
        self.isAuthenticated = true
        
        //27-11
        // 1. create a fresh profile manager
        self.profileViewModel = ProfileViewModel(appViewModel: self)
        print("AppViewModel: created new ProfileViewModel instance: \(String(describing: self.profileViewModel))")

        Task {
            // 2. force profile fetch
            print("AppViewModel: starting fetchProfile(for: \(user.id))")
            await self.profileViewModel?.fetchProfile(for: user.id)
            print("AppViewModel: fetchProfile completed — profile id in viewModel: \(String(describing: self.profileViewModel?.profile?.id))")
            
            // 3. start Firestore listener
            print("AppViewModel: starting listener for uid = \(user.id)")
            self.profileViewModel?.startListening(uid: user.id)
        }
        //27-11
    }
        
    
    func handleLogout() {
        print("AppViewModel.handleLogout() called — clearing profile state")
        ProfileService.shared.resetProfileState()
        self.profileViewModel?.stopListening()
        self.profileViewModel = nil
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
