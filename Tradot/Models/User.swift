//
//  User.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 20/10/2025.
//

import Foundation

enum UserRole: String, Codable {
    case client
    case technician
}

struct User: Codable,Identifiable {
    
    var id: String
    var name: String
    var email: String
    var phone: String?
    var role: UserRole
    var skills: [String]?
    var location: String?
    var rating: Double?
    // var availability: Bool
    // var profileImage: String?
    
    init(id: String = UUID().uuidString,
             name: String = "",
             email: String = "",
             phone: String? = nil,
             role: UserRole = .client,
             skills: [String]? = nil,
             location: String? = nil,
             rating: Double? = nil) {
            self.id = id
            self.name = name
            self.email = email
            self.phone = phone
            self.role = role
            self.skills = skills
            self.location = location
            self.rating = rating
        }
      
}
