import SwiftUI

struct SiteEditView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    let site: Site?

    @State private var name: String = ""
    @State private var deadline: Date = Date()
    @State private var budget: String = ""
    @State private var imageData: Data?
    @State private var selectedWorkerIds: Set<UUID> = []
    @State private var showImagePicker = false

    private var isEditing: Bool { site != nil }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 16) {
                        imageSection
                        nameSection
                        deadlineSection
                        budgetSection
                        workersSection
                    }
                    .padding(16)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear(perform: loadData)
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(imageData: $imageData)
        }
    }

    private var header: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundColor(AppTheme.accent)

            Spacer()

            Text(isEditing ? "Edit Site" : "New Site")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Button("Save") { save() }
                .foregroundColor(name.isEmpty ? AppTheme.textSecondary : AppTheme.accent)
                .disabled(name.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
    }

    private var imageSection: some View {
        Button { showImagePicker = true } label: {
            ZStack {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                } else {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppTheme.accent.opacity(0.08))
                        .frame(height: 160)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.title2)
                                Text("Add Photo")
                                    .font(.caption)
                            }
                            .foregroundColor(AppTheme.accent)
                        )
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Site Name")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("Enter site name", text: $name)
                .textFieldStyle(.plain)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Deadline")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            DatePicker("", selection: $deadline, displayedComponents: .date)
                .labelsHidden()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Budget ($)")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("0", text: $budget)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var workersSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Assign Workers")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)

            if storage.workers.isEmpty {
                Text("No workers available. Add workers first.")
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
                            toggleWorker(worker.id)
                        } label: {
                            HStack {
                                Image(systemName: selectedWorkerIds.contains(worker.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedWorkerIds.contains(worker.id) ? AppTheme.accent : AppTheme.textSecondary)
                                Text(worker.name.isEmpty ? "Unnamed" : worker.name)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Text(worker.specialization)
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

    private func toggleWorker(_ id: UUID) {
        if selectedWorkerIds.contains(id) {
            selectedWorkerIds.remove(id)
        } else {
            selectedWorkerIds.insert(id)
        }
    }

    private func loadData() {
        guard let site = site else { return }
        name = site.name
        deadline = site.deadline
        budget = site.budget > 0 ? String(format: "%.0f", site.budget) : ""
        imageData = site.imageData
        selectedWorkerIds = Set(site.workerIds)
    }

    private func save() {
        let budgetValue = Double(budget) ?? 0
        if var existing = site {
            existing.name = name
            existing.deadline = deadline
            existing.budget = budgetValue
            existing.imageData = imageData
            existing.workerIds = Array(selectedWorkerIds)
            storage.updateSite(existing)
        } else {
            let newSite = Site(
                name: name,
                imageData: imageData,
                deadline: deadline,
                budget: budgetValue,
                workerIds: Array(selectedWorkerIds)
            )
            storage.addSite(newSite)
        }
        dismiss()
    }
}

#Preview("New Site") {
    SiteEditView(site: nil)
        .environmentObject(LocalStorage.preview)
}

#Preview("Edit Site") {
    let storage = LocalStorage.preview
    SiteEditView(site: storage.sites[0])
        .environmentObject(storage)
}
