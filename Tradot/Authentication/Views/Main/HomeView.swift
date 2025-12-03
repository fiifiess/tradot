//
//  HomeView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            if let user = profileViewModel.profile {
                switch user.role {
                case "client":
                    PostJobView()
                        .environmentObject(appViewModel)
                        .environmentObject(authViewModel)
                    
                case "technician":
                    JobListView()
                        .environmentObject(appViewModel)
                        .environmentObject(authViewModel)
                default:
                    Text("Unsupported Role")
                }
            } else {
                ProgressView("Loading user...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onReceive(appViewModel.$currentUser) { _ in
            // Force refresh when user role updates
            print(appViewModel.$currentUser)
        }
    }// end of body View
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let appVM = AppViewModel()
        let profileVM = ProfileViewModel(appViewModel: appVM)
        HomeView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
            .environmentObject(profileVM)
    }
}
