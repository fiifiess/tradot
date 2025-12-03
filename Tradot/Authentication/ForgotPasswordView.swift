//
//  ForgotPasswordView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 16){
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Enter your new password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Re-enter your new password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Reset Password"){
                Task{ await authViewModel.sendPasswordReset(to: authViewModel.email)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
    }
}
