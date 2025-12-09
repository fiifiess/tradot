//
//  ProfileViewModel.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 31/10/2025.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var profile: Profile?{
        didSet {
            Task {
                await fetchSavedJobs()
                await fetchPostedJobs()
            }
        }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var newSkill: String = ""
    @Published var savedJobs: [Job] = []
    @Published var assignedJobs: [Job] = []
    @Published var postedJobs: [Job] = []             
    weak var appViewModel: AppViewModel?
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    
    // This(profileImage) is a change I have added. Confirm it.
    @Published var profileImage: Image? = nil
    
    let profileService = ProfileService.shared
    let jobService = JobService.shared

    
    var displayRate: String {
        guard let rate = profile?.rate else {
            return "No rate set"
        }
        return String(rate)
    }
    
    var displayName: String {
        guard let name = profile?.name, let role = profile?.role else {
            return "Unknown user"
        }
        switch role.lowercased(){
        case "technician":
            return "Technician \(name)"
        case "client":
            return "\(name)"
        default:
            return name
        }
    }
    
    var isTechnician: Bool {
        return profile?.role == "technician"
    }
    
    func fetchProfile(for userId: String) async {
        print("ProfileViewModel.fetchProfile() called with uid = \(userId)")
        isLoading = true
        do {
            let fetchedProfile = try await profileService.fetchProfile(uid: userId)
            self.profile = fetchedProfile
            print("ProfileViewModel.fetchProfile(): fetchedProfile.id = \(fetchedProfile.id), name = \(fetchedProfile.name)")
            await fetchSavedJobs() // 25-11
            await fetchPostedJobs() // 26-11
        } catch {
            self.errorMessage = error.localizedDescription
            print("ProfileViewModel.fetchProfile() FAILED for uid=\(userId): \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func saveProfile(_ profile: Profile) async {
        isLoading = true
        do {
            try await profileService.updateProfile(profile)
            self.profile = profile
            print("✅ Firestore document updated successfully for ID: \(profile.id)")
            print("🔗 Saved imageUrl: \(profile.imageUrl ?? "nil")")
            
            if let appVM = appViewModel,
               var user = appVM.currentUser {

                user.name = profile.name
                
                // Convert String → UserRole
                if let newRole = UserRole(rawValue: profile.role ?? "client") {
                    user.role = newRole
                }

                user.email = profile.email 

                appVM.currentUser = user
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                print("❌ saveProfile error: \(error.localizedDescription)")
            }
        }
        isLoading = false
    }
    
    func updateProfileField(field: ProfileField, value: Any) async {
        guard var currentProfile = profile else { return }
        
        switch field {
        case .name:
            currentProfile.name = value as? String ?? currentProfile.name
        case .city:
            currentProfile.city = value as? String ?? currentProfile.city
        case .speciality:
            currentProfile.speciality = value as? String
        case .skills:
            currentProfile.skills = value as? [String]
        case .imageUrl:
            currentProfile.imageUrl = value as? String
        }
        
        do {
            try await profileService.updateProfileField(uid: currentProfile.id, field: field.rawValue, value: value)
            self.profile = currentProfile
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func uploadProfileImage(image: UIImage) async throws -> String {
        isLoading = true
        defer { isLoading = false } // ensure we reset loading at the end

        do {
            print("🚀 Starting uploadProfileImage...")

            // Upload to Firebase Storage
            let imageUrl = try await profileService.uploadProfileImage(image)
            print("✅ Upload succeeded. URL returned: \(imageUrl)")

            // Update the profile in memory
            if var updatedProfile = profile {
                updatedProfile.imageUrl = imageUrl
                print("🧩 Updating profile for user ID: \(updatedProfile.id)")
                print("🧩 imageUrl set to: \(updatedProfile.imageUrl ?? "nil")")

                await saveProfile(updatedProfile)
                print("✅ Profile saved successfully to Firestore.")
            } else {
                print("⚠️ No existing profile found in memory. Fetching...")
                if let userId = Auth.auth().currentUser?.uid {
                    await fetchProfile(for: userId)
                    if var reloaded = profile {
                        reloaded.imageUrl = imageUrl
                        await saveProfile(reloaded)
                        print("✅ Profile fetched and updated.")
                    } else {
                        print("❌ Still no profile found after fetch.")
                    }
                }
            }

            // ✅ Return the URL string at the very end
            return imageUrl

        } catch {
            print("❌ Error in uploadProfileImage: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            throw error  // propagate the error
        }
    }
    
    
    func deleteProfile() async {
        guard let userId = profile?.id else { return }
        isLoading = true
        do {
            try await profileService.deleteProfile(uid: userId)
            profile = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func addSkill(){
        guard !newSkill.isEmpty else { return }
        if profile?.skills == nil { profile?.skills = [] }
        profile?.skills?.append(newSkill)
    }
    
    func removeSkill(_ skill: String){
        profile?.skills?.removeAll { $0 == skill }
    }
    
    
    enum ProfileField: String {
        case name
        case city
        case speciality
        case skills
        case imageUrl
    }
    // MARK: - Job Tracking Helpers
    
    // Adds a job ID to the client's list of posted jobs
    func addJobToPostedJobs(jobId: String) async {
        guard var currentProfile = profile else { return }
        
        //Ensure array exists
        if currentProfile.jobsPosted == nil {
            currentProfile.jobsPosted = []
        }
        
        // Prevent duplicates
        if !(currentProfile.jobsPosted?.contains(jobId) ?? false){
            currentProfile.jobsPosted?.append(jobId)
        }
        
        do {
            try await profileService.updateProfileField(uid: currentProfile.id, field: "jobsPosted", value: currentProfile.jobsPosted ?? [])
            self.profile = currentProfile
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
    }
    
    // Adds a job ID to the technician's saved jobs
    func addJobToSavedJobs(jobId: String) async {
        guard var currentProfile = profile else { return }
        
        if currentProfile.savedJobs == nil {
            currentProfile.savedJobs = []
        }
        
        if !(currentProfile.savedJobs?.contains(jobId) ?? false) {
            currentProfile.savedJobs?.append(jobId)
        }
        
        do {
            try await profileService.updateProfileField(uid: currentProfile.id, field: "savedJobs", value: currentProfile.savedJobs ?? [])
            self.profile = currentProfile
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func fetchSavedJobs() async {
        guard let technicianId = profile?.id else { return }
        do {
            let profile = try await profileService.fetchProfile(uid: technicianId)
            let jobIds = profile.savedJobs ?? []
            self.savedJobs = try await jobService.getJobsWithIds(jobIds)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
 
    func fetchPostedJobs() async {
        guard let clientId = profile?.id else { return }
        do {
            let profile = try await profileService.fetchProfile(uid: clientId)
            let jobIds = profile.jobsPosted ?? []
            self.postedJobs = try await jobService.getJobsWithIds(jobIds)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func addJobToAssignedJobs(jobId: String) async {}
    func fetchAssignedJobs() async {}
    
    
    // MARK: - Listener for real-time updates
    func startListening(uid: String) {
        print("ProfileViewModel.startListening() called for uid = \(uid)")
        profileService.listenToProfile(uid: uid) { [weak self] updatedProfile in
            DispatchQueue.main.async {
                print("ProfileViewModel.listener: received update for profile.id = \(updatedProfile.id)")
                self?.profile = updatedProfile
                Task {
                    await self?.fetchSavedJobs()   // Update accepted jobs whenever profile changes
                    await self?.fetchPostedJobs()   // Update posted jobs whenever profile changes
                }
            }
        }
    }

    func stopListening() {
        profileService.removeProfileListener()
    }
    
    func resetCache() {
        ProfileService.shared.clearCachedProfile() 
    }

  
}
