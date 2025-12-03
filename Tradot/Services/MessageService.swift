//
//  MessageService.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 18/11/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class MessageService {
    static let shared = MessageService()
    
    private init(){}
    private let db = Firestore.firestore()
    
    // MARK: - Conversations
    
    func fetchConversations(for userId: String) async throws -> [Conversation]{
        let snapshot = try await db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .getDocuments()
        return snapshot.documents.compactMap {
            try? $0.data(as: Conversation.self)
        }
    }
    
    func createConversation(_ conversation: Conversation ) async throws {
        try db.collection("conversations").document(conversation.id).setData(from: conversation)
    }
    
    func fetchMessages(conversationId: String) async throws ->  [Message] {
        let snapshot = try await db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap {
            try? $0.data(as: Message.self)
            
        }
    }
    
    func sendMessage(_ message: Message, in conversationId: String) async throws {
        try db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document(message.id)
            .setData(from: message)
    }
}

extension MessageService {
    // Listen to messages in real time for a conversation
    func listenToMessages(conversationId: String,
                          onChange: @escaping ([Message]) -> Void) -> ListenerRegistration {
        
        let db = Firestore.firestore()
        
        return db.collection("messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error  in
                if let error = error {
                    print("❌ Error listening to messages: \(error.localizedDescription)")
                    onChange([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    onChange([])
                    return
                }
                
                let messages: [Message] = documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                }
                
                onChange(messages)
            }
    }
    
    // Listen to conversations in real time.
    func listenToConversations(for userId: String, handler: @escaping ([Conversation]) -> Void) -> ListenerRegistration {
        return db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let docs = snapshot?.documents {
                    let conversations = docs.compactMap { try? $0.data(as: Conversation.self) }
                    handler(conversations)
                } else {
                    handler([])
                }
            }
    }
}
