//
//  RegisterView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 16){
                TextField("Name", text: $authViewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Email", text: $authViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Password", text: $authViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !(authViewModel.errorMessage?.isEmpty ?? false) {
                    Text(authViewModel.errorMessage ?? "Something wrong with your password")
                        .foregroundColor(.red)
                }
                
                Button("Sign Up"){
                    Task{ await authViewModel.signUp() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Register")
            .onAppear{
                authViewModel.appViewModel = appViewModel
            }
        }
        
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
    }
}
