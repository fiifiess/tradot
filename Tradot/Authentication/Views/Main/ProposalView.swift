//
//  ProposalView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 06/12/2025.
//

import SwiftUI

struct ProposalView: View {
    var job: Job
    
    @State private var amount: String = ""
    @State private var etaDays: String = ""
    @State private var message: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    
    // Validation state
    private var isFormValid: Bool {
        guard let _ = Double(amount), !amount.isEmpty else { return false }
        guard !etaDays.isEmpty else { return false }
        guard !message.isEmpty else { return false }
        return true
    }
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var proposalViewModel : ProposalViewModel
    @EnvironmentObject var profileViewModel : ProfileViewModel
    
    var body: some View {
        NavigationStack{
            Form{
                Section(header: Text("Bid Amount")){
                    TextField("Amount in USD", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Estimated Completion Time")){
                    TextField("Days (e.g.: 2)", text: $etaDays)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Bidding Pitch")){
                    TextField("Write a short message", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section{
                    Button(action: submitProposal) {
                        Text("Submit Proposal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }// end of Form
            .navigationTitle("Propose a Bid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }// end of toolbar
            
        }// end of Navigation Stack
    }// end of View
    
    // MARK: Submit Logic
    private func submitProposal() {
        guard let technicianId = profileViewModel.profile?.id else { return }
        guard let amountValue = Double(amount) else { return }

        let proposal = Proposal(
            jobId: job.id,
            technicianId: technicianId,
            amount: amountValue,
            etaDays: etaDays,
            message: message
        )
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            await proposalViewModel.postProposal(proposal)
            isSubmitting = false
            dismiss()
        }
    }
}

struct ProposalView_Previews: PreviewProvider {
    static var previews: some View {
        let appVM = AppViewModel()
        let profileVM = ProfileViewModel(appViewModel: appVM)

        return ProposalView(job: Job(id: "1", title: "Test", description: "Desc", clientId: "c1", technicianId: nil, price: 20, status: .open, location: "NY"))
            .environmentObject(appVM)
            .environmentObject(profileVM)
            .environmentObject(ProposalViewModel())
    }
}
