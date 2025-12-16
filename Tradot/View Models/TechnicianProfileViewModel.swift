//
//  TechnicianProfileViewModel.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 15/12/2025.
//

import Foundation

import Foundation
import SwiftUI


@MainActor
final class TechnicianProfileViewModel: ObservableObject {
    
    @Published var profile: Profile?
    @Published var assignedJobs: [Job] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let profileService = ProfileService.shared
    private let jobService = JobService.shared
    
    /// Read-only public profile fetch
    func fetchTechnicianProfile(technicianId: String) async {
        print("TechnicianVieModel: fetchTechnicianProfile entered...")
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await profileService.fetchProfileById(technicianId)
            self.profile = fetched
            print("Fetched profile \(fetched.id)")
            await fetchWorkHistory(from: fetched.workHistory ?? [])
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // Change this to the one that fetches Assigned Jobs
    private func fetchWorkHistory(from jobIds: [String]) async {
        guard !jobIds.isEmpty else {
            self.assignedJobs = []
            return
        }
        do {
            self.assignedJobs = try await jobService.getJobsWithIds(jobIds)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    
    // MARK: - Convenience accessors (read-only)
    var displayName: String { profile?.name ?? "Unknown" }
    var city: String { profile?.city ?? "" }
    var ratingText: String {
        guard let rating = profile?.rating else { return "No rating" }
        return String(format: "%.1f", rating)
    }
    var skills: [String] { profile?.skills ?? [] }
    var bio: String { profile?.bio ?? "" }
    
}
