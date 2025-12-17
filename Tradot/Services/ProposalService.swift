//
//  ProposalService.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 04/12/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProposalService {
    static let shared = ProposalService()
    private let db = Firestore.firestore()
    private init(){}
    
    // Post a proposal
    func postProposal(_ proposal: Proposal) async throws -> String {
        let proposalsRef = db.collection("jobs").document(proposal.jobId).collection("proposals")
        let docRef = proposalsRef.document()
        var p = proposal
        p.id = docRef.documentID
        try docRef.setData(from: p)
        return p.id!
    }
    
    // Listen to proposals for a job
    func listenToProposals(jobId: String, handler: @escaping ([Proposal]) -> Void) -> ListenerRegistration {
        return db.collection("jobs").document(jobId)
            .collection("proposals")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else {
                    handler([])
                    return
                }
                let proposals = docs.compactMap { try? $0.data(as: Proposal.self)}
                handler(proposals)
            }
    }
    
    // Update an individual proposal (accept/reject/withdraw)
    func updateProposal(_ proposal: Proposal) async throws {
        guard let id = proposal.id else { return }
        let ref = db.collection("jobs").document(proposal.jobId).collection("proposals").document(id)
        try ref.setData(from: proposal, merge: true)
    }
    
    // Accept a proposal: transactional to update job & proposals atomically (use batched writes or Firestore transaction)
    func acceptProposal(_ proposal: Proposal) async throws {
        guard let proposalId = proposal.id else {
            print("❌ acceptProposal: Proposal has no ID")
            return
        }

        let jobRef = db.collection("jobs").document(proposal.jobId)
        let proposalsRef = jobRef.collection("proposals")
        let chosenRef = proposalsRef.document(proposalId)

        // --- Simple batched write version (no transaction) ---
        // 1. Update job + chosen proposal
        let batch = db.batch()

        batch.updateData([
            "status": "assigned",
            "assignedTechnicianId": proposal.technicianId,
            "updatedAt": FieldValue.serverTimestamp()
        ], forDocument: jobRef)

        batch.updateData([
            "status": ProposalStatus.accepted.rawValue
        ], forDocument: chosenRef)

        // 2. Reject all other proposals
        let snapshot = try await proposalsRef.getDocuments()
        for doc in snapshot.documents {
            if doc.documentID == proposalId { continue }
            let otherRef = proposalsRef.document(doc.documentID)
            batch.updateData([
                "status": ProposalStatus.rejected.rawValue
            ], forDocument: otherRef)
        }

        // 3. Commit batch
        try await batch.commit()
        print("✅ Proposal accepted successfully")
        
        let techRef = db.collection("profiles").document(proposal.technicianId)
        try await techRef.updateData([
            "assignedJobs": FieldValue.arrayUnion([proposal.jobId])
        ])
    }
    
    // Reject a proposal
    func rejectProposal(_ proposal: Proposal) async throws {
        guard let id = proposal.id else { return }
        let ref = db.collection("jobs").document(proposal.jobId).collection("proposals").document(id)
        try await ref.updateData([
            "status": ProposalStatus.rejected.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // Withdraw a proposal (technician cancels their own proposal)
    func withdrawProposal(_ proposal: Proposal) async throws {
        guard let id = proposal.id else { return }
        let ref = db.collection("jobs").document(proposal.jobId).collection("proposals").document(id)
        try await ref.updateData([
            "status": ProposalStatus.withdrawn.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // Cancel a job (client cancels): resets job + rejects all proposals
    func cancelJob(jobId: String) async throws {
        let jobRef = db.collection("jobs").document(jobId)
        let proposalsRef = jobRef.collection("proposals")
        
        let batch = db.batch()
        
        // 1. Update job
        batch.updateData([
            "status": "cancelled",
            "assignedTechnicianId": NSNull(),
            "updatedAt": FieldValue.serverTimestamp()
        ], forDocument: jobRef)
        
        // 2. Reject all proposals
        let snapshot = try await proposalsRef.getDocuments()
        for doc in snapshot.documents {
            let ref = proposalsRef.document(doc.documentID)
            batch.updateData([
                "status": ProposalStatus.rejected.rawValue
            ], forDocument: ref)
        }
        
        try await batch.commit()
    }
    
    // Real‑time updates for accepted proposal
    func listenToAcceptedProposal(jobId: String, handler: @escaping (Proposal?) -> Void) -> ListenerRegistration {
        return db.collection("jobs").document(jobId)
            .collection("proposals")
            .whereField("status", isEqualTo: ProposalStatus.accepted.rawValue)
            .addSnapshotListener { snapshot, error in
                guard let doc = snapshot?.documents.first,
                      let proposal = try? doc.data(as: Proposal.self) else {
                    handler(nil)
                    return
                }
                handler(proposal)
            }
    }
    
    func fetchProposals(for jobId: String) async throws -> [Proposal] {
        let snapshot = try await db.collection("jobs")
            .document(jobId)
            .collection("proposals")
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Proposal.self) }
    }
    
    


}
