//
//  ProfileService.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 31/10/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

class ProfileService {
    // Code from 25-11
    private var profileListener: ListenerRegistration?
    // Code from 25-11
    
    static let shared = ProfileService()
    private init() {}
    
    // Firebase References
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Local cache key
    private let profileKey = "cachedUserProfile"
    
    func createProfile(userID: String, name: String, email: String) async throws {
        let profile = Profile(id: userID, name: name, email: email)
        try await db.collection("profiles").document(userID).setData([
            "id": profile.id,
            "name": profile.name,
            "email": profile.email,
        ])
        cacheProfile(profile) // Cache immediately
    }
    
    func fetchProfile(uid: String, ignoreCache: Bool = false) async throws -> Profile {
        if !ignoreCache, let cached = loadCachedProfile() {
            return cached
        }

        print("ProfileService.fetchProfile() — fetching uid = \(uid), ignoreCache = \(ignoreCache)")
        let document = try await db.collection("profiles").document(uid).getDocument()

        print("ProfileService.fetchProfile(): document.exists = \(document.exists)")
//        guard document.exists, let data = document.data() else {
//            throw NSError(domain: "ProfileService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
//        }
        guard document.exists else {
            throw NSError(
                domain: "ProfileService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Profile not found (no document)"]
            )
        }

        guard let data = document.data() else {
            throw NSError(
                domain: "ProfileService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Profile not found (no data)"]
            )
        }

        print("ProfileService.fetchProfile(): document.data keys = \(Array(data.keys))")

        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let profile = try JSONDecoder().decode(Profile.self, from: jsonData)
        cacheProfile(profile)
        return profile
    }
    
    
    // MARK: - Update / Save Profile
    func updateProfile(_ profile: Profile) async throws {
        let data = try JSONEncoder().encode(profile)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        
        print("📤 Writing to Firestore (document: \(profile.id)) with data:")
        print(jsonObject)
        
        try await db.collection("profiles").document(profile.id).setData(jsonObject)
        cacheProfile(profile)
        
        print("✅ Firestore write complete.")
    }
    
    // MARK: - Delete Profile
    func deleteProfile(uid: String) async throws {
        try await db.collection("profiles").document(uid).delete()
        clearCachedProfile()
    }
    
    // MARK: - Upload Profile Image
    func uploadProfileImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "ProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"])
        }
        
        let fileName = UUID().uuidString + ".jpg"
        let ref = storage.reference().child("profile_images/\(fileName)")
        
        _ = try await ref.putDataAsync(imageData, metadata: nil)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    func updateProfileField(uid: String, field: String, value: Any) async throws {
        try await db.collection("profiles").document(uid).updateData([field: value])
        
        // Update local cache if it exists
        if var cachedProfile = loadCachedProfile() {
            let mirror = Mirror(reflecting: cachedProfile)
            if mirror.children.contains(where: { $0.label == field }) {
                // Dynamic property update via reflection is limited — handle manually for known fields
                switch field {
                case "name":
                    if let name = value as? String { cachedProfile.name = name }
                case "city":
                    if let city = value as? String { cachedProfile.city = city }
                case "speciality":
                    if let speciality = value as? String { cachedProfile.speciality = speciality }
                case "skills":
                    if let skills = value as? [String] { cachedProfile.skills = skills }
                case "imageUrl":
                    if let url = value as? String { cachedProfile.imageUrl = url }
                default:
                    break
                }
                cacheProfile(cachedProfile)
            }
        }
    }
    
    // Add a job ID to the client's posted jobs
    func addJobToJobsPosted(jobId: String, userId: String) async throws {
        
        let profileRef = db.collection("profiles").document(userId)
        let snapshot = try await profileRef.getDocument()
        if !snapshot.exists { return }
        guard let profileData = snapshot.data() else { return }
        
        var jobsPosted = profileData["jobsPosted"] as? [String] ?? []
        if !jobsPosted.contains(jobId) {
            jobsPosted.append(jobId)
            try await profileRef.updateData(["jobsPosted": jobsPosted])
        } 
    }
    
    // Add a job ID to the technician's saved jobs
    func addJobToSavedJobs(jobId: String, userId: String) async throws {
        
        print("🔵 ENTERED addJobToSavedJobs")
        print("Received jobId = \(jobId)")
        print("Received userId = \(userId)")
        
        let profileRef = db.collection("profiles").document(userId)
        let snapshot = try await profileRef.getDocument()
        
        if snapshot.exists {
            print("✅ Profile document EXISTS for user \(userId)")
        } else {
            print("❌ Profile document does NOT exist for user \(userId)")
        }
        
        if !snapshot.exists {
            print("❌ Profile document NOT FOUND for user \(userId)")
            return
        }
        guard let profileData = snapshot.data() else {
            print("❌ snapshot.data() is nil for user \(userId)")
            return
        }
        
        var savedJobs = profileData["savedJobs"] as? [String] ?? []
        print("Existing savedJobs ARRAY = \(savedJobs)")
        if !savedJobs.contains(jobId) {
            print("🟢 Adding jobId \(jobId) to savedJobs")
            savedJobs.append(jobId)
            try await profileRef.updateData(["savedJobs": savedJobs])
            print("✅ Successfully updated saved jobs in Firestore")
        } else {
            print("⚠️ JobId already exists in savedJobs")
        }
    }
    
    // Code from 25 -11
    // MARK: - Real‑time Listener
       /// Starts listening for profile changes in Firestore.
    func listenToProfile(uid: String, onChange: @escaping (Profile) -> Void) {
        // Remove old listener if any
        profileListener?.remove()
        
        profileListener = db.collection("profiles").document(uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Profile listener error: \(error.localizedDescription)")
                    return
                }
                print("ProfileService.listener: snapshot exists = \(snapshot?.exists ?? false), hasData = \(snapshot?.data() != nil)")
                guard let data = snapshot?.data() else {
                    print("ProfileService.listener: snapshot.data() is nil — skipping")
                    return
                }
                print("ProfileService.listener: data keys = \(Array(data.keys))")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let profile = try JSONDecoder().decode(Profile.self, from: jsonData)
                    
                    print("🔥 assignedJobs updated: \(profile.assignedJobs ?? [])")
                    
                    self.cacheProfile(profile)
                    onChange(profile)
                } catch {
                    print("❌ Failed to decode profile in listener: \(error.localizedDescription)")
                }
            }
    }

    /// Stops listening for profile updates
    func removeProfileListener() {
        profileListener?.remove()
        profileListener = nil
    }
    
    // Code from 25 -11
    

    
    // MARK: - Local Caching
    func cacheProfile(_ profile: Profile) {
        do {
            let data = try JSONEncoder().encode(profile)
            UserDefaults.standard.set(data, forKey: profileKey)
        } catch {
            print("Error caching profile: \(error.localizedDescription)")
        }
    }
    
    func loadCachedProfile() -> Profile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        do {
            return try JSONDecoder().decode(Profile.self, from: data)
        } catch {
            print("Error loading cached profile: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearCachedProfile() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
    
    // MARK: - Reset Profile State (Logout Helper)
    func resetProfileState() {
        removeProfileListener()
        clearCachedProfile()
    }
    
    /// Fetch a public profile by explicit user ID (used for technician profiles)
    func fetchProfileById(_ uid: String) async throws -> Profile {
        let snapshot = try await db
            .collection("profiles")
            .document(uid)
            .getDocument()

        guard snapshot.exists else {
            throw NSError(domain: "ProfileService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Profile not found"
            ])
        }

        return try snapshot.data(as: Profile.self)
    }
    
    
}
