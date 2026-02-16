import SwiftUI

struct AddShiftView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    var preselectedDate: Date

    @State private var selectedWorkerId: UUID?
    @State private var selectedSiteId: UUID?
    @State private var date: Date = Date()
    @State private var hours: String = "8"

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        workerPicker
                        sitePicker
                        dateSection
                        hoursSection
                    }
                    .padding(16)
                }
            }
        }
        .onAppear {
            date = preselectedDate
            selectedWorkerId = storage.workers.first?.id
            selectedSiteId = storage.sites.first?.id
        }
    }

    private var header: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundColor(AppTheme.accent)

            Spacer()

            Text("Add Shift")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Button("Save") { save() }
                .foregroundColor(canSave ? AppTheme.accent : AppTheme.textSecondary)
                .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
    }

    private var workerPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Worker")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)

            if storage.workers.isEmpty {
                Text("No workers available")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.smallCornerRadius)
            } else {
                VStack(spacing: 0) {
                    ForEach(storage.workers) { worker in
                        Button {
                            selectedWorkerId = worker.id
                        } label: {
                            HStack {
                                Image(systemName: selectedWorkerId == worker.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedWorkerId == worker.id ? AppTheme.accent : AppTheme.textSecondary)
                                Text(worker.name.isEmpty ? "Unnamed" : worker.name)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Text(String(format: "$%.0f/hr", worker.hourlyRate))
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)

                        if worker.id != storage.workers.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
    }

    private var sitePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Site")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)

            if storage.sites.isEmpty {
                Text("No sites available")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.smallCornerRadius)
            } else {
                VStack(spacing: 0) {
                    ForEach(storage.sites) { site in
                        Button {
                            selectedSiteId = site.id
                        } label: {
                            HStack {
                                Image(systemName: selectedSiteId == site.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedSiteId == site.id ? AppTheme.accent : AppTheme.textSecondary)
                                Text(site.name.isEmpty ? "Unnamed" : site.name)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)

                        if site.id != storage.sites.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Date")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hours")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("8", text: $hours)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)

            if let workerId = selectedWorkerId,
               let worker = storage.worker(by: workerId),
               let h = Double(hours) {
                Text(String(format: "Cost: $%.0f", h * worker.hourlyRate))
                    .font(.caption)
                    .foregroundColor(AppTheme.accent)
            }
        }
    }

    private var canSave: Bool {
        selectedWorkerId != nil && selectedSiteId != nil && Double(hours) != nil && (Double(hours) ?? 0) > 0
    }

    private func save() {
        guard let workerId = selectedWorkerId,
              let siteId = selectedSiteId,
              let h = Double(hours), h > 0 else { return }

        let shift = Shift(workerId: workerId, siteId: siteId, date: date, hours: h)
        storage.addShift(shift)
        dismiss()
    }
}

#Preview {
    AddShiftView(preselectedDate: Date())
        .environmentObject(LocalStorage.preview)
}
