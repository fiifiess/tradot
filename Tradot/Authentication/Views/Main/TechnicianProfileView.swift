//
//  TechnicianProfileView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 15/12/2025.
//

import SwiftUI

struct TechnicianProfileView: View {
    
    @EnvironmentObject var jobViewModel: JobViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @StateObject private var technicianProfileViewModel = TechnicianProfileViewModel()
    @State private var jobs: [Job] = []
    @State private var isLoading = true
    @State private var selectedJob: Job? = nil
    let technicianId: String
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Profile Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(technicianProfileViewModel.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(technicianProfileViewModel.city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Rating: \(technicianProfileViewModel.ratingText)")
                        .font(.subheadline)
                }
                // MARK: - Skills
                if !technicianProfileViewModel.skills.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skills")
                            .font(.headline)
                        //WrapView is defined in ProfileView for wrapping text boxes.
                        WrapView(items: technicianProfileViewModel.skills) {  skill in 
                            Text(skill)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
                // MARK: - Bio
                if !technicianProfileViewModel.bio.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bio")
                            .font(.headline)
                        Text(technicianProfileViewModel.bio)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                // MARK: - Assigned Jobs
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assigned Jobs")
                        .font(.headline)
                    if technicianProfileViewModel.assignedJobs.isEmpty {
                        Text("No assigned jobs yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(technicianProfileViewModel.assignedJobs) { job in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(job.title)
                                    .font(.headline)
                                Text(job.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("$\(job.price, specifier: "%.2f")")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(job.location ?? "")
                                        .foregroundColor(.secondary)
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Technician Profile")
        .navigationBarBackButtonHidden(false)
        .task {
            await //technicianProfilViewModel.fetchTechnicianProfile(technicianId: technicianId)
            loadSelectedJobs()
        }
    }
    
    func loadSelectedJobs() async {
        guard let selectedIds = profileViewModel.profile?.assignedJobs, !selectedIds.isEmpty else {
            isLoading = false
            return
        }
        isLoading = true
        var loadedJobs: [Job] = []
        for jobId in selectedIds {
            if let job = await jobViewModel.fetchJob(by: jobId) {
                loadedJobs.append(job)
            }
        }
        self.jobs = loadedJobs
        isLoading = false
    }
}

struct TechnicianProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let appVM = AppViewModel()
        TechnicianProfileView(technicianId: "1234")
            .environmentObject(JobViewModel())
            .environmentObject(ProfileViewModel(appViewModel: appVM))
    }
}
