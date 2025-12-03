//
//  MessageViewModel.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 18/11/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let messageService = MessageService.shared
    private var conversationId: String
    
    init(conversationId: String) {
        self.conversationId = conversationId
    }
    
    func loadMessages() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await messageService.fetchMessages(conversationId: conversationId)
            messages = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func sendMessage(senderId: String, content: String) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = Message(
            senderId: senderId,
            content: content,
            timestamp: Date(),
            conversationId: conversationId
        )
        
        do {
            try await messageService.sendMessage(message, in: conversationId)
            messages.append(message)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Real-time listener
    private var listener: ListenerRegistration?
    
    func startListening(){
        stopListening()
        isLoading = true
        errorMessage = nil
        
        listener = messageService.listenToMessages(conversationId: conversationId) { [weak self] msgs in
            guard let self = self else { return }
            self.messages = msgs
            self.isLoading = false
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

