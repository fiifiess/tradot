//
//  Job.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 21/10/2025.
//

import Foundation

struct Job: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var price: Double
    var clientId: String
    var technicianId: String?
    var status: JobStatus
    var location: String?
    var createdAt: Date

    init(id: String = UUID().uuidString,
         title: String = "",
         description: String = "",
         clientId: String = "",
         technicianId: String? = nil,
         price: Double = 0,
         status: JobStatus = .pending,
         location: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.clientId = clientId
        self.technicianId = technicianId
        self.price = price
        self.status = status
        self.location = location
        self.createdAt = createdAt
        }
}

enum JobStatus: String, Codable {
    case open // Posted but not accepted by any technician yet
    case pending // Has been accepted and is currently being worked on.
    case accepted // Has been accepted 
    case completed // Has been accepted and completed
    case cancelled // Has been accepted but cancelled by either technician or client
}
