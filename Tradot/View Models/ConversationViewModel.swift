//
//  ConversationViewModel.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 19/11/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
final class ConversationViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading: Bool = false
    
    private var listener: ListenerRegistration?
    private let messageService = MessageService.shared
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        listenToConversations()
    }
    
    func listenToConversations() {
        listener?.remove()
        listener = messageService.listenToConversations(for: userId) { [weak self] conversations in
            Task { @MainActor in
                // Use sorted(by:) with explicit parameter types to resolve type inference
                self?.conversations = conversations.sorted(by: { (c1: Conversation, c2: Conversation) -> Bool in
                    let t1 = c1.messages.last?.timestamp ?? .distantPast
                    let t2 = c2.messages.last?.timestamp ?? .distantPast
                    return t1 > t2
                })
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
    
}
