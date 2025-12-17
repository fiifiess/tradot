//
//  JobService.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 03/11/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


final class JobService {
    
    private let db = Firestore.firestore()
    private let jobsCollection = "jobs"
    //private init() {}
    static let shared = JobService()
    
    
    func postJob(title: String,
                 description: String,
                 price: Double,
                 location: String?,
                 clientId: String) async throws -> String {
        let job = Job(
            id: UUID().uuidString,     // or let Job default to UUID if your model already generates it
            title: title,
            description: description,
            clientId: clientId,
            price: price,
            status: .open,
            location: location              // set initial status
            // other fields...
        )
        
        let jobRef = db.collection("jobs").document(job.id)
        try jobRef.setData(from: job)        // uses Codable
        return job.id
    }
    
    // 26-11
    
    func fetchOpenJobs() async throws -> [Job]{
        let snapshot = try await db.collection(jobsCollection)
            .whereField("status", in: ["open", "pending"])
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Job.self) }
    }
    
    func fetchClientJobs(clientId: String) async throws -> [Job]{
        let snapshot = try await db.collection(jobsCollection)
            .whereField("clientId", isEqualTo: clientId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Job.self) }
    }
    
    func fetchTechnicianJobs(technicianId: String) async throws -> [Job] {
        let snapshot = try await db.collection(jobsCollection)
            .whereField("technicianId", isEqualTo: technicianId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Job.self) }
    }
    
    func updateJob(_ job: Job) async throws {
        let jobRef = db.collection("jobs").document(job.id)
        try jobRef.setData(from: job, merge: true)
    }
    
    func updateJobStatus(jobId: String, status: String) async throws {
        try await db.collection(jobsCollection).document(jobId).updateData(["status": status])
    }
    
    func deleteJob(jobId: String) async throws {
            try await db.collection(jobsCollection).document(jobId).delete()
    }
    
    func editJob(jobId: String, title: String? = nil, description: String? = nil, price: Double? = nil, location: String? = nil, status: String? = nil) async throws {
        var updatedData: [String: Any] = [:]
        if let title = title { updatedData["title"] = title }
        if let description = description { updatedData["description"] = description }
        if let price = price { updatedData["price"] = price }
        if let location = location { updatedData["location"] = location }
        if let status = status { updatedData["status"] = status }
        
        guard !updatedData.isEmpty else { return }
        try await db.collection(jobsCollection).document(jobId).updateData(updatedData)
    }
    
    func filterJobs(keyword: String? = nil, minPrice: Double? = nil, maxPrice: Double? = nil, location: String? = nil) async throws -> [Job]{
        
        var query: Query = db.collection(jobsCollection).whereField("status", isEqualTo: "open")
        
        if let keyword = keyword, !keyword.isEmpty {
            query = query.whereField("title", isGreaterThanOrEqualTo: keyword).whereField("title", isLessThanOrEqualTo: keyword + "\u{f8ff}")
        }
        
        let snapshot = try await query.getDocuments()
        var jobs = snapshot.documents.compactMap{ try? $0.data(as: Job.self) }
        
        if let minPrice = minPrice {
            jobs = jobs.filter { $0.price >= minPrice }
        }
        
        if let maxPrice = maxPrice {
            jobs = jobs.filter { $0.price <= maxPrice }
        }
        
        if let location = location, !location.isEmpty {
            jobs = jobs.filter { ($0.location ?? "").lowercased().contains(location.lowercased()) }
        }
        
        return jobs
    }
}

// MARK: - Job Actions
extension JobService {
    
    /// Save a job: updates the job status, adds jobId to technician's workHistory and client's jobsPosted
    func saveJob(job: Job, technicianId: String) async throws {
        // Update job status
        let updatedJob = job
        try await updateJob(updatedJob)
        
        // Update technician's profile
        try await ProfileService.shared.addJobToSavedJobs(jobId: job.id, userId: technicianId)
        
        // Optionally ensure client has the jobId in jobsPosted (redundant if already added at creation)
    }
    
    /// Reject a job: update status
    func rejectJob(job: Job, technicianId: String) async throws {
        var updatedJob = job
        updatedJob.status = .open
        try await updateJob(updatedJob)
    }
    
    func getJobsWithIds(_ jobIds: [String]) async throws -> [Job] {
        if jobIds.isEmpty { return [] }

        let snapshot = try await db.collection("jobs")
            .whereField(FieldPath.documentID(), in: jobIds)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Job.self) }
    }
    
    func getJobById(_ jobId: String) async throws -> Job {
        let ref = db.collection("jobs").document(jobId)
        let snapshot = try await ref.getDocument()

        guard snapshot.data() != nil else {
            throw NSError(domain: "JobService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Job not found"
            ])
        }

        // Firestore-native decoding
        let job = try snapshot.data(as: Job.self)
        return job
    }


}
