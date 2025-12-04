//
//  Profile.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 30/10/2025.
//

import Foundation
import SwiftUI

struct Profile: Codable, Identifiable {
    
    var id: String
    var name: String
    var email: String
    var role: String?
    var imageUrl: String?
    var city: String?
    var rating: Double?
    var createdAt: Date? = Date()
    var updatedAt: Date? = nil
    var ratingCount: Int?
    var rate: Double?
    var bio: String?
    var imageGallery: [String]?
    var savedJobs: [String]?
    var workHistory: [String]?
    var jobsPosted: [String]?
    
    var speciality: String?
    var skills: [String]?
    
    var averageRating: String {
        guard let rating = rating, let count = ratingCount, count > 0 else {
            return "No ratings yet"
        }
        return String(format: "%.2f * (%d)", rating, count)
    }
}

extension Profile {
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.email = ""
        self.role = "client"
        self.imageUrl = nil
        self.city = ""
        self.rating = nil
        self.createdAt = Date()
        self.updatedAt = nil
        self.ratingCount = nil
        self.speciality = nil
        self.skills = []
        self.rate = nil
        self.bio = nil
        self.imageGallery = nil
        self.savedJobs = nil
        self.workHistory = nil
        self.jobsPosted = nil
    }
}

extension Profile {
    static func loadCurrentUserProfile(from viewModel: ProfileViewModel, userId: String) {
        Task { @MainActor in
            await viewModel.fetchProfile(for: userId)
        }
    }
}
