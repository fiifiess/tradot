//
//  JobDetailView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 13/11/2025.
//

import SwiftUI

struct JobDetailView: View {
    
    @State private var showProposalSheet = false
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var jobViewModel: JobViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @StateObject var proposalViewModel = ProposalViewModel()
    
    var job: Job
    
    var body: some View {
        ScrollView{
            VStack(spacing: 16){
                // Job Info card
                VStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8){
                        Text(job.title)
                            .font(.title2)
                            .bold()
                        Text(job.description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true) // allows multi-line wrapping
                        HStack{
                            Text("$\(job.price, specifier: "%.2f")")
                                .fontWeight(.medium)
                            Spacer()
                            Text(job.location ?? "")
                                .foregroundColor(.secondary)
                        }// end of HStack
                        Text(statusLabel(status: job.status))
                            .font(.caption)
                            .foregroundColor(statusColor(status: job.status))
                            .padding(.top, 6)
                    }
                    VStack{
                        //User Info Card
                        VStack(alignment: .center, spacing: 8){
                            Text(userLabel())
                                .font(.headline)
                            Text(userContact())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 2))
                        // end of VStack
                        
                        //Action Buttons
                        HStack(spacing: 16){
                            if userIsTechnician(){
                                Button("Save"){
                                    // Save action
                                    Task {
                                        guard let technicianId = profileViewModel.profile?.id else { return }
                                        await jobViewModel.saveJob(job, technicianId: technicianId)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button("Bid"){
                                    // Open the proposal view as a sheet
                                    showProposalSheet = true
                                }
                                .buttonStyle(.bordered)
                        
//                                    Task {
//                                        guard let technicianId = profileViewModel.profile?.id else { return }
//                                        await jobViewModel.rejectJob(job, technicianId: technicianId)
//                                    }
//                                }
//                                .buttonStyle(.bordered)
                            } else if userIsClient() {
                                Button("Edit"){
                                    // Edit action
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button("Delete"){
                                    // Delete action
                                }
                                .buttonStyle(.bordered)
                            }
                        }// end of HStack
                    }
                    
                }// end of Job Info Card
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 2))
                // end of VStack
                
                
            }
            .padding()// end of VStack
        } // end of Scroll View
        .sheet(isPresented: $showProposalSheet) {
            ProposalView(job: job)
                .environmentObject(proposalViewModel)
        }
    } // end of var body
    
    // MARK: -  Helper Functions

    func statusColor(status: JobStatus) -> Color {
        switch status {
        case .open: return .yellow
        case .pending: return .orange
        case .accepted: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }

    func statusLabel(status: JobStatus) -> String {
        switch status {
        case .open: return "Open"
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    func userLabel() -> String {
        // Replace with actual logic to show technician/client name
        return "Client Name"
    }

    func userContact() -> String {
        // Replace with actual contact info
        return "client@example.com"
    }

    func userIsTechnician() -> Bool {
        // Replace with logic to detect current user role
        return true
    }

    func userIsClient() -> Bool {
        return !userIsTechnician()
    }

}

struct JobDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleJob = Job(id: "1", title: "Sample Job", description: "Repair phone", clientId: "123", technicianId: nil, price: 50, status: .open, location: "Sydney")
        JobDetailView(job: sampleJob)
            .environmentObject(JobViewModel())
    }
}


