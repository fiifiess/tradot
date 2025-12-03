//
//  TradotApp.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    //FirebaseApp.configure()

    return true
  }
}


@main
struct TradotApp: App {
    @StateObject private var appViewModel: AppViewModel
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var jobViewModel: JobViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
        
        // Initialize all view models here
        let appVM = AppViewModel()
        let authVM = AuthViewModel()
        let jobVM = JobViewModel()
        let profileVM = ProfileViewModel(appViewModel: appVM)

        // Assign them to the StateObject wrappers
        _appViewModel = StateObject(wrappedValue: appVM)
        _authViewModel = StateObject(wrappedValue: authVM)
        _jobViewModel = StateObject(wrappedValue: jobVM)
        _profileViewModel = StateObject(wrappedValue: profileVM)

        // Link relationships AFTER initialization
        authVM.appViewModel = appVM
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .environmentObject(authViewModel)
                .environmentObject(jobViewModel)
                .environmentObject(profileViewModel)
        }
    }
}
