//
//  ProposalListView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 08/12/2025.
//

import SwiftUI

struct ProposalListView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var proposalViewModel: ProposalViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 16){
                    ForEach(proposalViewModel.proposals, id: \.self) { proposal in
                        ProposalCardView(
                            proposal: proposal,
                            onAccept: { proposal in
                                Task {
                                    await proposalViewModel.acceptProposal(proposal)
                                }
                            },
                            onReject: { proposal in
                                Task {
                                    await proposalViewModel.rejectProposal(proposal)
                                }
                            }
                        )
                    }
                }
                .padding(.top)
            } // end of ScrollView
            .navigationTitle("Proposals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                }
            }
        }// end of NavigationStack
    } // end of View
}

struct ProposalListView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AppViewModel()
        let proposalVM = ProposalViewModel()
        ProposalListView()
            .environmentObject(ProfileViewModel(appViewModel: vm))
            .environmentObject(proposalVM)
            .environmentObject(vm)
    }
}
