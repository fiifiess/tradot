//
//  Conversation.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 18/11/2025.
//

import Foundation

struct Conversation: Codable, Identifiable {
    var id: String = UUID().uuidString
    var participants: [String]
    var messages: [Message]
    var lastMessage: Message?{
        messages.last
    }
    var updatedAt: Date = Date()
    var jobId: String
}
