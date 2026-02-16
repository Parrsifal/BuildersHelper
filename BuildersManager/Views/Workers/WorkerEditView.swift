import SwiftUI

struct WorkerEditView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    let worker: Worker?

    @State private var name: String = ""
    @State private var specialization: String = ""
    @State private var education: String = ""
    @State private var experience: String = ""
    @State private var hourlyRate: String = ""
    @State private var photoData: Data?
    @State private var showImagePicker = false

    private var isEditing: Bool { worker != nil }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        photoSection
                        nameSection
                        specializationSection
                        educationSection
                        experienceSection
                        rateSection
                    }
                    .padding(16)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear(perform: loadData)
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(imageData: $photoData)
        }
    }

    private var header: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundColor(AppTheme.accent)

            Spacer()

            Text(isEditing ? "Edit Worker" : "New Worker")
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

    private var photoSection: some View {
        Button { showImagePicker = true } label: {
            ZStack {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                    .font(.title3)
                                Text("Photo")
                                    .font(.caption2)
                            }
                            .foregroundColor(AppTheme.accent)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Full Name")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("Enter name", text: $name)
                .textFieldStyle(.plain)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var specializationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Specialization")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("e.g. Electrician, Plumber", text: $specialization)
                .textFieldStyle(.plain)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Education")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextEditor(text: $education)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 60)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var experienceSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Experience")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextEditor(text: $experience)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 60)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var rateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hourly Rate ($)")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("0", text: $hourlyRate)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private func loadData() {
        guard let worker = worker else { return }
        name = worker.name
        specialization = worker.specialization
        education = worker.education
        experience = worker.experience
        hourlyRate = worker.hourlyRate > 0 ? String(format: "%.0f", worker.hourlyRate) : ""
        photoData = worker.photoData
    }

    private func save() {
        let rate = Double(hourlyRate) ?? 0
        if var existing = worker {
            existing.name = name
            existing.specialization = specialization
            existing.education = education
            existing.experience = experience
            existing.hourlyRate = rate
            existing.photoData = photoData
            storage.updateWorker(existing)
        } else {
            let newWorker = Worker(
                name: name,
                specialization: specialization,
                education: education,
                experience: experience,
                hourlyRate: rate,
                photoData: photoData
            )
            storage.addWorker(newWorker)
        }
        dismiss()
    }
}

#Preview("New Worker") {
    WorkerEditView(worker: nil)
        .environmentObject(LocalStorage.preview)
}

#Preview("Edit Worker") {
    let storage = LocalStorage.preview
    WorkerEditView(worker: storage.workers[0])
        .environmentObject(storage)
}
