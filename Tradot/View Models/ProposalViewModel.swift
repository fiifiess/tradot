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
        } catch{
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
}
