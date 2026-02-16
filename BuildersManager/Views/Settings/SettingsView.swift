import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var company: String = ""
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 14) {
                        profileSection
                        appSection
                        dangerZone
                    }
                    .padding(16)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            name = storage.profile.name
            company = storage.profile.company
        }
    }

    private var header: some View {
        HStack {
            Button { saveAndDismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(AppTheme.accent)
            }

            Spacer()

            Text("Settings")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Spacer().frame(width: 50)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground.ignoresSafeArea(edges: .top))
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Profile", systemImage: "person.circle.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                TextField("Your name", text: $name)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppTheme.background)
                    .cornerRadius(AppTheme.smallCornerRadius)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Company")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                TextField("Company name", text: $company)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppTheme.background)
                    .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
        .cardStyle()
    }

    private var appSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("About", systemImage: "info.circle.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            HStack {
                Text("Version")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("1.0.0")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }

            HStack {
                Text("Sites")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(storage.sites.count)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }

            HStack {
                Text("Workers")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(storage.workers.count)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }

            if let url = URL(string: "https://www.termsfeed.com/live/f29340e4-05ff-4a2b-963a-6ef134959c2b") {
                Link(destination: url) {
                    HStack {
                        Text("Privacy Policy")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.accent)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .cardStyle()
    }

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Data", systemImage: "exclamationmark.triangle.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            Button {
                storage.hasSeenOnboarding = false
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset Onboarding")
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(AppTheme.accent)
                .padding(12)
                .background(AppTheme.accent.opacity(0.06))
                .cornerRadius(AppTheme.smallCornerRadius)
            }

            Button { showResetConfirm = true } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete All Data")
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(AppTheme.destructive)
                .padding(12)
                .background(AppTheme.destructive.opacity(0.06))
                .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
        .cardStyle()
        .alert("Delete All Data", isPresented: $showResetConfirm) {
            Button("Delete", role: .destructive) {
                storage.sites = []
                storage.workers = []
                storage.shifts = []
                storage.expenses = []
                storage.profile = UserProfile()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all sites, workers, shifts, and expenses. This cannot be undone.")
        }
    }

    private func saveAndDismiss() {
        storage.profile = UserProfile(name: name, company: company)
        dismiss()
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocalStorage.preview)
}
