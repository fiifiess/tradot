//
//  RootView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 21/10/2025.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack{
            if appViewModel.isAuthenticated {
                MainTabView()
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            } else {
                AuthFlowView()
                    .transition(.move(edge: .leading))
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appViewModel.isAuthenticated)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
    }
}
