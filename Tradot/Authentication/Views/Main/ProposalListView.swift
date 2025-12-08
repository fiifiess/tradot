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
                    proposalCard(amount: proposal.amount, eta: proposal.etaDays ?? "", message: proposal.message)
                    }
                }
                .padding(.top)
            } // end of ScrollView
        } // end of VStack
        .padding()
        
    } // end of View
    
    // MARK: - Proposal Card Component
    @ViewBuilder
    func proposalCard(amount: Double, eta: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text("$\(amount, specifier: "%.2f")")
                    .font(.title3)
                    .bold()
                Spacer()
                Text(eta)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } // end of HStack
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
        } // end of VStack
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 2))
        
    } // end of proposalCard
} // end of struct

struct ProposalListView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AppViewModel()
        let proposalVM = ProposalViewModel()
        ProposalListView()
            //.environmentObject(AppViewModel())
            .environmentObject(ProfileViewModel(appViewModel: vm))
            .environmentObject(proposalVM)
    }
}
