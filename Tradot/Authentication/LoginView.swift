//
//  LoginView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 16){
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = authViewModel.errorMessage {
                Text(error.isEmpty ? "Something wrong with your password" : error)
                    .foregroundColor(.red)
            }
            
            Button("Login"){
                Task{ await authViewModel.logIn() }
            }
            .buttonStyle(.borderedProminent)
            
        }
        .padding()
        .navigationTitle("Login")
        .onAppear {
            authViewModel.appViewModel = appViewModel
            Task { @MainActor in
                if let userId = authViewModel.authService.currentUser()?.id {
                    await profileViewModel.fetchProfile(for: userId)
                    print("📦 Profile fetched on appear: \(profileViewModel.profile?.imageUrl ?? "No image URL")")
                }
            }
        }
    }
}






struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let appVM = AppViewModel()
        LoginView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
            .environmentObject(ProfileViewModel(appViewModel: appVM))
        
    }
}
