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
    
    var body: some View {
        VStack(spacing: 16){
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
//            if !(authViewModel.errorMessage?.isEmpty ?? false) {
//                Text(authViewModel.errorMessage ?? "Something wrong with your password")
//                    .foregroundColor(.red)
//            }
            
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
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
        
    }
}
