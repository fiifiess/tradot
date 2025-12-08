//
//  ProposalListView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 08/12/2025.
//

import SwiftUI

struct ProposalListView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var proposalViewModel: ProposalViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack{
            Text("Proposals")
                .font(.largeTitle)
                .bold()
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
        } // end of VStack
        .padding()
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
