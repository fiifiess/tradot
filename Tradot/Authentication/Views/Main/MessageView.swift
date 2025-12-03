//
//  MessageView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 19/11/2025.
//

import SwiftUI

struct MessageView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var viewModel: MessageViewModel
    var partnerName: String
    @State private var messageText: String = ""
    
    
    var body: some View {
        VStack{
            HStack{
                Button(action: { /* navigation handled outside */ }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                Text(partnerName)
                    .font(.headline)
                Spacer()
            }
            .padding()// end of HStack
            
            //Message list
            ScrollViewReader{ proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)// end of lazy v stack
                }
                .onChange(of: viewModel.messages){_ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                // end of scroll view
            }// end of Scroll View Reader
            
            // Input bar
            HStack{
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: send){
                    Image(systemName: "paperplane.fill")
                }
            }
            .padding()
            // end of HStack
        }
        .onAppear { viewModel.startListening() }
        .onDisappear{ viewModel.startListening() }
        // end of VStack
    }
    // end of body View
    
    // MARK: - Bubble
    @ViewBuilder
    func messageBubble(_ message: Message) -> some View {
        let isCurrentUser = message.senderId == appViewModel.currentUser?.id
        
        HStack{
            if isCurrentUser { Spacer() }
            Text(message.content)
                .padding(12)
                .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isCurrentUser ? .white : .primary)
                .cornerRadius(16)
            if !isCurrentUser { Spacer() }
        } // end of HStack
        
    }
    
    // MARK: - Actions
    func send(){
        guard let uid = appViewModel.currentUser?.id else { return }
        Task { await viewModel.sendMessage(senderId: uid, content: messageText) }
        messageText = ""
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let messageVM = MessageViewModel(conversationId: "1234")
        MessageView(viewModel: messageVM, partnerName: "Bra John")
    }
}
