//
//  SelectedJobsView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 09/12/2025.
//

import SwiftUI
import FirebaseFirestore

struct AssignedJobsView: View {
    
    @EnvironmentObject var jobViewModel: JobViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @State private var jobs: [Job] = []
    @State private var isLoading = true
    @State private var selectedJob: Job? = nil
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading selected jobs...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if jobs.isEmpty {
                Text("No selected jobs yet.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(jobs) { job in
                    Button {
                        selectedJob = job
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
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
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Selected Jobs")
        .task {
            await loadSelectedJobs()
        }
        .sheet(item: $selectedJob) { job in
            JobDetailView(job: job)
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

struct SelectedJobsView_Previews: PreviewProvider {
    static var previews: some View {
        AssignedJobsView()
    }
}
