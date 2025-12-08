//
//  ProposalCardView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 08/12/2025.
//

import SwiftUI
import FirebaseFirestore

struct ProposalCardView: View {
    let proposal: Proposal
    let onAccept: (Proposal) -> Void
    let onReject: (Proposal) -> Void

    @State private var technicianName: String = "Loading…"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Technician Name
            Text(technicianName)
                .font(.headline)

            HStack {
                Text("$\(proposal.amount, specifier: "%.2f")")
                    .font(.title3)
                    .bold()
                Spacer()
                Text(proposal.etaDays ?? "N/A")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(proposal.message)
                .font(.body)
                .foregroundColor(.primary)

            HStack {
                Button("Accept") {
                    onAccept(proposal)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button("Reject") {
                    onReject(proposal)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 2))
        .task { await fetchTechnicianName() }
    }

    private func fetchTechnicianName() async {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("profiles").document(proposal.technicianId).getDocument()
            if let name = snapshot.get("name") as? String {
                technicianName = name
            } else {
                technicianName = "Unknown"
            }
        } catch {
            technicianName = "Unknown"
        }
    }
}

struct ProposalCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let sampleProposal = Proposal(
            id: "1",
            jobId: "job1",
            technicianId: "tech1",
            amount: 120.0,
            etaDays: "3 days",
            message: "Can fix it quickly.",
            status: .pending
        )
        
        ProposalCardView(
            proposal: sampleProposal,
            onAccept: { _ in print("Accepted") },
            onReject: { _ in print("Rejected") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
