//
//  SwiftUIView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 13/11/2025.
//

import SwiftUI

struct JobListView: View {
    
    @EnvironmentObject var jobViewModel: JobViewModel
    @State private var selectedJob: Job? = nil
    @State private var showingAcceptedJobs = false
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Text("Available Jobs")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    NavigationLink(value: "SavedJobs") {
                        Text("My Saved Jobs")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                if jobViewModel.isLoading {
                    ProgressView("Loading jobs...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if jobViewModel.jobs.isEmpty {
                    Text("No Jobs Available")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(jobViewModel.jobs){ job in
                        Button(action: {
                            selectedJob = job
                        }) {
                            VStack(alignment: .leading, spacing: 6){
                                Text(job.title)
                                    .font(.headline)
                                Text(job.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack{
                                    Text("$\(job.price, specifier: "%.2f")")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(job.location ?? "")
                                        .foregroundColor(.secondary)
                                } // end of HStack
                            }
                            .padding(.vertical, 8)
                            // end of VStack
                        }
                    }
                    .listStyle(.plain)
                    // end of List
                }
            }// end of VStack
            .navigationDestination(for: String.self) { value in
                if value == "SavedJobs" {
                    SavedJobsView().environmentObject(jobViewModel)
                }
            }
            .task {
                await jobViewModel.fetchOpenJobs()
            }
            .sheet(item: $selectedJob){ job in
                JobDetailView(job: job)
            }
        }// end of Navigation Stack
    }
}

struct JobListView_Previews: PreviewProvider {
    static var previews: some View {
        JobListView()
            .environmentObject(JobViewModel())
    }
}
