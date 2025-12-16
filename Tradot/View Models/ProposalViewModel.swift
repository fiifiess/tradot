//
//  ProposalViewModel.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 05/12/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ProposalViewModel: ObservableObject {
    @Published var proposals: [Proposal] = []
    @Published var acceptedProposal: Proposal? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var proposalsListener: ListenerRegistration? = nil
    private var acceptedListener: ListenerRegistration? = nil
    private let jobService = JobService()
    
//    weak var appViewModel: AppViewModel?
//    
//    init(appViewModel: AppViewModel) {
//        self.appViewModel = appViewModel
//    }
    
    func stopListeners() {
        proposalsListener?.remove()
        acceptedListener?.remove()
    }
    
    // MARK: - Listen to all proposals for a job
    func listenToProposals(jobId: String){
        proposalsListener?.remove()
        proposalsListener = ProposalService.shared.listenToProposals(jobId: jobId) { [weak self] proposals in
            self?.proposals = proposals
        }
    }
    
    // MARK: - Listen for accepted proposal
    func listenToAccepted(jobId: String){
        acceptedListener?.remove()
        acceptedListener = ProposalService.shared.listenToAcceptedProposal(jobId: jobId) { [weak self] proposal in
            self?.acceptedProposal = proposal
        }
    }
    
    func postProposal(_ proposal: Proposal) async {
        isLoading = true
        do{
            _ =  try await ProposalService.shared.postProposal(proposal)
            // 2️⃣ Fetch the job
            var job = try await jobService.getJobById(proposal.jobId) //else {
//                throw NSError(domain: "ProposalViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Job not found"])
//            }
            // 3️⃣ Update status if still open
            if job.status == .open {
                job.status = .pending
                try await jobService.updateJob(job)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func acceptProposal(_ proposal: Proposal) async {
        isLoading = true
        do{
            _ = try await ProposalService.shared.acceptProposal(proposal)
        } catch{
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    func rejectProposal(_ proposal: Proposal) async {
        isLoading = true
        do{
            _ = try await ProposalService.shared.rejectProposal(proposal)
        } catch{
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    func withdrawProposal(_ proposal: Proposal) async {
        isLoading = true
        do{
            _ = try await ProposalService.shared.withdrawProposal(proposal)
        } catch{
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    func cancelJob(jobId: String) async {
        isLoading = true
        do{
            _ = try await ProposalService.shared.cancelJob(jobId: jobId)
        } catch{
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchProposals(for jobId: String) async {
        isLoading = true
        do {
            let fetched = try await ProposalService.shared.fetchProposals(for: jobId)
            await MainActor.run {
                self.proposals = fetched
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
        
    }
    

}
