import SwiftUI

struct WorkerDetailView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    let workerId: UUID

    @State private var showEditWorker = false
    @State private var showDeleteConfirm = false

    private var worker: Worker? { storage.worker(by: workerId) }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                detailHeader

                if let worker = worker {
                    ScrollView {
                        VStack(spacing: 14) {
                            profileSection(worker)
                            infoSection(worker)
                            sitesSection(worker)
                            shiftsSection(worker)
                            deleteButton
                        }
                        .padding(16)
                        .padding(.bottom, 20)
                    }
                } else {
                    Spacer()
                    Text("Worker not found")
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showEditWorker) {
            if let worker = worker {
                WorkerEditView(worker: worker)
            }
        }
        .alert("Delete Worker", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let worker = worker {
                    storage.deleteWorker(worker)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the worker and all associated shifts. This action cannot be undone.")
        }
    }

    private var detailHeader: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(AppTheme.accent)
            }

            Spacer()

            Text(worker?.name ?? "Worker")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            Spacer()

            Button { showEditWorker = true } label: {
                Text("Edit")
                    .foregroundColor(AppTheme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
    }

    private func profileSection(_ worker: Worker) -> some View {
        VStack(spacing: 12) {
            if let data = worker.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(AppTheme.accent.opacity(0.12))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.accent)
                    )
            }

            Text(worker.name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            Text(worker.specialization.isEmpty ? "No specialization" : worker.specialization)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)

            Text(String(format: "$%.0f/hr", worker.hourlyRate))
                .font(.headline)
                .foregroundColor(AppTheme.accent)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private func infoSection(_ worker: Worker) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if !worker.education.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Education", systemImage: "graduationcap.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(worker.education)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                }
            }

            if !worker.experience.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Experience", systemImage: "briefcase.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(worker.experience)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func sitesSection(_ worker: Worker) -> some View {
        let workerSites = storage.sitesForWorker(worker)

        return VStack(alignment: .leading, spacing: 10) {
            Label("Assigned Sites (\(workerSites.count))", systemImage: "building.2.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            if workerSites.isEmpty {
                Text("Not assigned to any site")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(workerSites) { site in
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppTheme.accent)
                            .font(.caption)
                        Text(site.name)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text(site.deadline, style: .date)
                            .font(.caption2)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func shiftsSection(_ worker: Worker) -> some View {
        let workerShifts = storage.shiftsForWorker(worker.id)
        let totalHours = workerShifts.reduce(0) { $0 + $1.hours }
        let totalEarned = totalHours * worker.hourlyRate

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Shift History", systemImage: "clock.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.0f hours", totalHours))
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(String(format: "$%.0f earned", totalEarned))
                        .font(.caption)
                        .foregroundColor(AppTheme.accent)
                }
            }

            if workerShifts.isEmpty {
                Text("No shifts recorded")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(workerShifts.sorted(by: { $0.date > $1.date }).prefix(10)) { shift in
                    let site = storage.site(by: shift.siteId)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(site?.name ?? "Unknown Site")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(shift.date, style: .date)
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text(String(format: "%.0fh · $%.0f", shift.hours, shift.hours * worker.hourlyRate))
                            .font(.caption)
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var deleteButton: some View {
        Button {
            showDeleteConfirm = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Worker")
            }
            .font(.subheadline)
            .foregroundColor(AppTheme.destructive)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(AppTheme.destructive.opacity(0.08))
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
}

#Preview {
    let storage = LocalStorage.preview
    WorkerDetailView(workerId: storage.workers[0].id)
        .environmentObject(storage)
}
