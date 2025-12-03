//
//  Message.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 18/11/2025.
//

import Foundation

struct Message: Codable, Identifiable, Hashable, Equatable {
    let id: String
    let senderId: String
    let content: String
    let timestamp: Date
    let isRead: Bool
    let conversationId: String
    
    init(id: String = UUID().uuidString,
         senderId: String,
         content: String,
         timestamp: Date = Date(),
         isRead: Bool = false,
         conversationId: String) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.conversationId = conversationId
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
