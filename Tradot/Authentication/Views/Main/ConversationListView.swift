////
////  ConversationListView.swift
////  Tradot
////
////  Created by Fiifi!!!!!  on 20/11/2025.
////
//
//import SwiftUI
//
//
//struct ConversationListView: View {
//    @EnvironmentObject var appViewModel: AppViewModel
//    @StateObject private var viewModel: ConversationViewModel
//    
//    
//    init(userId: String) {
//        _ viewModel = StateObject(wrappedValue: ConversationViewModel(userId: userId))
//    }
//    
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(viewModel.conversations) { conversation in
//                    HStack {
//                        Text(conversation.participants.first(where: { $0 != appViewModel.currentUser?.id }) ?? "Unknown")
//                            .font(.headline)
//                        Spacer()
//                        if let lastMessage = conversation.lastMessage {
//                            Text(lastMessage.content)
//                                .font(.subheadline)
//                                .lineLimit(1)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Conversations")
//            .overlay(Group {
//                if viewModel.isLoading {
//                    ProgressView()
//                } else if let error = viewModel.errorMessage {
//                    Text(error).foregroundColor(.red).padding()
//                } else if viewModel.conversations.isEmpty {
//                    Text("No conversations yet.").foregroundColor(.secondary)
//                }
//            })
//        }
//        .onAppear {
//            viewModel.listenToConversations()
//        }
//    }
//}
//
//struct ConversationListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationListView(userId: "preview-user-123")
//            .environmentObject(AppViewModel())
//    }
//}
