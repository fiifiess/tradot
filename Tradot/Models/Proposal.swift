//
//  Proposal.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 04/12/2025.
//

import Foundation
import FirebaseFirestoreSwift

enum ProposalStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case withdrawn
}

struct Proposal: Codable, Identifiable, Hashable {
    @DocumentID var id: String? = nil
    var jobId: String
    var technicianId: String
    var amount: Double
    var etaDays: String?
    var message: String
    var createdAt: Date = Date()
    var status: ProposalStatus = .pending
    var isAccepted: Bool?
    var isRejected: Bool?
}
