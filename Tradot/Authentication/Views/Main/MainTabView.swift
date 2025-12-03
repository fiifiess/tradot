//
//  MainTabView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView{
            HomeView()
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            ProfileView()
                .tabItem{
                    Label("Profile", systemImage: "person.circle")
                }
        }
        
    }

}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
    }
}
