//
//  PostJobView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 13/11/2025.
//

import SwiftUI

struct PostJobView: View {
    @StateObject private var jobViewModel = JobViewModel()
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var location: String = ""
    @State private var category: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmationSheet = false
    @State private var showErrorAlert = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @State private var selectedJob: Job? = nil
    @State private var showingPostedJobs = false
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    Text("Post a New Job")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    NavigationLink(value: "PostedJobs") {
                        Text("My Posted Jobs")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    VStack (spacing: 20){
                        
                        TextField("Job Title", text: $title)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Job Description")
                                    .foregroundColor(.gray)
                                    .padding(12)
                            }
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        TextField("Price / Rate ($)", text: $price)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        
                        TextField("Location", text: $location)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        
                        TextField("Category / Speciality (Optional)", text: $category)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        
                        if let errorMessage = jobViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .onAppear {
                                    showErrorAlert = true
                                }
                        }
                        
                        Button( action : {
                            Task{
                                guard let priceValue = Double(price) else { return }
                               
                                guard let clientId = profileViewModel.profile?.id else { return }
                                
                                // Post the job using this client ID
                                
                                await jobViewModel.postJob(
                                    title: title,
                                    description: description,
                                    price: priceValue,
                                    location: location,
                                    clientId: clientId 
                                )
                                
                                if jobViewModel.jobPostSuccess {
                                    withAnimation(.spring()) {
                                        showConfirmationSheet = true
                                    }
                                }
                            }
                        }) {
                            HStack {
                                if jobViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Post Job")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    // End of VStack
                }
                .blur(radius: showConfirmationSheet ? 4 : 0)
                .disabled(showConfirmationSheet)
                
                if showConfirmationSheet {
                    ConfirmationSheet(show: $showConfirmationSheet, dismiss: dismiss)
                        .transition(.scale.combined(with: .opacity))
                }// End of Scroll View
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(jobViewModel.errorMessage ?? "An unknown error occurred.")
            }// End of VStack
            .navigationDestination(for: String.self) { value in
                if value == "PostedJobs" {
                    PostedJobsView().environmentObject(jobViewModel)
                }
            }
            .sheet(item: $selectedJob){ job in
                JobDetailView(job: job)
            }
            
        }// End of Navigation Stack
    }// End of body View
}// End of PostJobView struct


struct ConfirmationSheet: View {
    @Binding var show: Bool
    var dismiss: DismissAction
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                
                Text("Job Posted Successfully!")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation(.spring()) {
                        show = false
                        dismiss()
                    }
                }) {
                    Text("Done")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(40)
        }
    }
}


struct PostJobView_Previews: PreviewProvider {
    static var previews: some View {
        PostJobView()
            .environmentObject(AppViewModel())
            .environmentObject(AuthViewModel())
    }
}
