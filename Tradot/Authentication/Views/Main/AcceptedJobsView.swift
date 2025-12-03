import SwiftUI

struct AcceptedJobsView: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @State private var selectedJob: Job? = nil

    var body: some View {
        VStack {
            Text("My Accepted Jobs")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)

            if profileViewModel.isLoading {
                ProgressView("Loading jobs...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if profileViewModel.acceptedJobs.isEmpty {
                    Text("No accepted jobs yet.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(profileViewModel.acceptedJobs) { job in
                        Button(action: {
                            selectedJob = job
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(job.title)
                                    .font(.headline)
                                Text(job.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("$\(job.price, specifier: "%.2f")")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(job.location ?? "")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        } // end VStack
        .onAppear {
            // Ensure acceptedJobs are up to date
            Task {
                if (profileViewModel.profile?.id) != nil {
                    await profileViewModel.fetchAcceptedJobs()
                }
            }
        }
        .sheet(item: $selectedJob) { job in
            JobDetailView(job: job)
        }
    }
}

struct AcceptedJobsView_Previews: PreviewProvider {
    static var previews: some View {
        let appVM = AppViewModel()
        AcceptedJobsView()
            .environmentObject(ProfileViewModel(appViewModel: appVM))
    }
}
