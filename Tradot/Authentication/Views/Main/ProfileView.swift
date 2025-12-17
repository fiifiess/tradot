//
//  ProfileView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutConfirmation = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showRemovePhotoAlert = false
    
//    init() {
//        // Initialize profile to avoid nil checks in the view
//        if profileViewModel.profile == nil {
//            profileViewModel.profile?.role = "technician"
//        }
//    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        if let image = profileViewModel.profileImage {
                            VStack(spacing: 8) {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    Text("Change Photo")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        } else {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(Text("Add Photo").font(.caption))
                            }
                        }
                    }
                    .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                                profileViewModel.profileImage = Image(uiImage: uiImage)
                                
                                // 1. Upload image and get URL
                                if let imageUrl = try? await profileViewModel.uploadProfileImage(image: uiImage),
                                   var profile = profileViewModel.profile {
                                    
                                    // 2. Update profile object
                                    profile.imageUrl = imageUrl
                                    profileViewModel.profile = profile
                                    
                                    // 3. Persist to Firestore
                                    await profileViewModel.saveProfile(profile)
                                }
                            }
                        }
                    }
                    .alert("Remove Photo", isPresented: $showRemovePhotoAlert) {
                        Button("Remove", role: .destructive) {
                            Task {
                                profileViewModel.profileImage = nil
                                if let userId = authViewModel.authService.currentUser()?.id {
                                    try? await profileViewModel.profileService.updateProfileField(uid: userId, field: "imageUrl", value: "")
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to remove your profile photo?")
                    }
                    
                    if profileViewModel.profile?.role == "technician" {
                        if let rate = profileViewModel.profile?.rate {
                            Text(String(format: "Rate: %.2f", rate))
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    
                    VStack(spacing: 10) {
                        
//                        // 🔄 Runtime role toggle (Uber-style)
//                        Toggle(
//                            "Switch to Technician Mode",
//                            isOn: Binding(
//                                get: { appViewModel.activeRole == "technician" },
//                                set: { isOn in
//                                    appViewModel.activeRole = isOn ? "technician" : "client"
//                                }
//                            )
//                        )
//                        .toggleStyle(SwitchToggleStyle(tint: .blue))
//
                        
                        Picker("Role", selection: Binding(
                            get: { profileViewModel.profile?.role ?? "client" },
                            set: { newValue in
                                if profileViewModel.profile == nil {
                                    profileViewModel.profile = Profile(name: "")
                                }
                                profileViewModel.profile?.role = newValue
                            })
                        ) {
                            Text("Client").tag("client")
                            Text("Technician").tag("technician")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        TextField( "Name", text: Binding(
                            get: { profileViewModel.profile?.name ?? "" },
                            set: { newValue in
                                if profileViewModel.profile == nil {
                                    profileViewModel.profile = Profile(name: newValue)
                                } else {
                                    profileViewModel.profile?.name = newValue
                                }
                            })
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField( "City", text: Binding(
                            get: { profileViewModel.profile?.city ?? "" },
                            set: { profileViewModel.profile?.city = $0 })
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if profileViewModel.profile?.role == "technician" {
                            TextField("Speciality", text: Binding(
                                get: { profileViewModel.profile?.speciality ?? "" },
                                set: { profileViewModel.profile?.speciality = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bio")
                                    .font(.headline)
                                TextEditor(text: Binding(
                                    get: { profileViewModel.profile?.bio ?? "" },
                                    set: { profileViewModel.profile?.bio = $0 }
                                ))
                                .frame(minHeight: 100, maxHeight: 200)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Skills")
                                    .font(.headline)
                                HStack {
                                    TextField("Add skill", text: $profileViewModel.newSkill)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Button(action: {
                                        Task { @MainActor in
                                            profileViewModel.addSkill()
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                    }
                                }
                                
                                if let skills = profileViewModel.profile?.skills, !skills.isEmpty {
                                    WrapView(items: skills) { skill in
                                        HStack {
                                            Text(skill)
                                            Button(action: { profileViewModel.removeSkill(skill) }) {
                                                Image(systemName: "xmark.circle.fill")
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            
                            
                            if let imageGallery = profileViewModel.profile?.imageGallery, !imageGallery.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Image Gallery")
                                        .font(.headline)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(imageGallery, id: \.self) { imageName in
                                                Image(imageName)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .clipped()
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 40)
                            }
                        }
                        
                    }
                    .padding([.leading, .trailing], 32)
                    

                    
                    VStack {
                        Button(action: {
                            if let profile = profileViewModel.profile {
                                Task { await profileViewModel.saveProfile(profile) }
                            }
                        }) {
                            Text("Save changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 20)
                        
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            Text("Sign Out")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .alert(isPresented: $showLogoutConfirmation) {
                            Alert(
                                title: Text("Confirm Logout"),
                                message: Text("Are you sure you want to logout?"),
                                primaryButton: .destructive(Text("Logout")) {
                                    authViewModel.logOut()
                                    print(appViewModel.isAuthenticated)
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    .padding()
                }
                
            }
            .navigationTitle("Profile")
//            .onAppear {
//                Task { @MainActor in
//                    if let userId = authViewModel.authService.currentUser()?.id {
//                        await profileViewModel.fetchProfile(for: userId)
//                        print("📦 Profile fetched on appear: \(profileViewModel.profile?.imageUrl ?? "No image URL")")
//                    }
//                }
//            }
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let appVM = AppViewModel()
        let profileVM = ProfileViewModel(appViewModel: appVM)

        return ProfileView()
            .environmentObject(appVM)
            .environmentObject(AuthViewModel())
            .environmentObject(profileVM)
    }
}

struct WrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    
    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \ .self) { item in
                self.content(item)
                    .padding(4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == items.last! {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geometry.size.height
            }
            return .clear
        }
    }
}
