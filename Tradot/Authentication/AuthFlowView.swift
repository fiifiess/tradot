//
//  RootView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 21/10/2025.
//

import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 16) {
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                NavigationLink(destination: RegisterView()) {
                    Text("Register")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Forgot Password?")
                        .font(.body)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }
}

struct AuthFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AuthFlowView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
    }
}
