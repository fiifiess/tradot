//
//  JobViewModel.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 03/11/2025.
//

import Foundation

@MainActor
final class JobViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isLoading = false
    @Published var errorMessage : String?
    @Published var jobPostSuccess = false
    @Published var selectedJob: Job?
    @Published var savedJobs: [Job] = []
    @Published var postedJobs: [Job] = []
    @Published var assignedJobs: [Job] = []
    
    private var jobService = JobService.shared
    private var profileService = ProfileService.shared
    
//    init(jobService: JobService = JobService()){
//        self.jobService = jobService
//    }

    func postJob(title: String, description: String, price: Double, location: String, clientId: String) async {
        isLoading = true
        errorMessage = nil
        jobPostSuccess = false

        do {
            let jobId = try await jobService.postJob(
                title: title,
                description: description,
                price: price,
                location: location,
                clientId: clientId
            )

            try await profileService.addJobToJobsPosted(jobId: jobId, userId: clientId)

            jobPostSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    
    func fetchOpenJobs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            jobs = try await jobService.fetchOpenJobs()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchClientJobs(clientId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            jobs = try await jobService.fetchClientJobs(clientId: clientId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateJobStatus(jobId: String, status: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await jobService.updateJobStatus(jobId: jobId, status: status)
            // Refresh jobs array after updating
            await fetchOpenJobs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchTechnicianJobs(technicianId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            jobs = try await jobService.fetchTechnicianJobs(technicianId: technicianId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteJob(jobId: String) async {
        isLoading = true
        errorMessage = nil
        
        do{
            try await jobService.deleteJob(jobId: jobId)
            await fetchOpenJobs() // Refresh list after deletion
        } catch{
            errorMessage = error.localizedDescription
        }
    }
    
    func editJob(jobId: String, title: String? = nil, description: String? = nil, price: Double? = nil, location: String? = nil, status: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do{
            try await jobService.editJob(jobId: jobId, title: title, description: description, price: price, location: location, status: status)
        } catch{
            errorMessage = error.localizedDescription
        }
    }
    
    func filterJobs(keyword: String? = nil, minPrice: Double? = nil, maxPrice: Double? = nil, location: String? = nil) async -> [Job]{
        isLoading = true
        errorMessage = nil
        
        do{
            jobs = try await jobService.filterJobs(keyword: keyword, minPrice: minPrice, maxPrice: maxPrice, location: location)
        } catch{
            errorMessage = error.localizedDescription
        }
        return jobs
    }
    
    // Save Job
    func saveJob(_ job: Job, technicianId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Update job status
            try await jobService.saveJob(job: job, technicianId: technicianId)
            
            // Add to technician's work history
            try await profileService.addJobToSavedJobs(jobId: job.id, userId: technicianId)
            print("JobViewModel.saveJob has added job \(job.id) to \(technicianId)'s saved jobs")
            
            // Add to client's jobsPosted if necessary (optional, usually already added when job created)
            // try await profileService.addJobToJobsPosted(jobId: job.id, userId: job.clientId)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Reject Job
    func rejectJob(_ job: Job, technicianId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await jobService.rejectJob(job: job, technicianId: technicianId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAcceptedJobs(for technicianId: String) async {
        do {
            let profile = try await profileService.fetchProfile(uid: technicianId)

            let jobIds = profile.workHistory ?? []
            savedJobs = try await jobService.getJobsWithIds(jobIds)

        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAssignedJobs(for technicianId: String) async {
        do {
            let profile = try await profileService.fetchProfile(uid: technicianId)

            let jobIds = profile.assignedJobs ?? []
            assignedJobs = try await jobService.getJobsWithIds(jobIds)


        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchJob(by id: String) async -> Job? {
        do {
            return try await jobService.getJobById(id)
        } catch {
            print("❌ Failed to fetch job: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
}
   
