import SwiftUI

struct WorkerCardView: View {
    let worker: Worker

    var body: some View {
        HStack(spacing: 12) {
            workerAvatar

            VStack(alignment: .leading, spacing: 4) {
                Text(worker.name.isEmpty ? "Unnamed" : worker.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(worker.specialization.isEmpty ? "No specialization" : worker.specialization)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.0f", worker.hourlyRate))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accent)
                Text("/hr")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
        }
        .cardStyle()
    }

    @ViewBuilder
    private var workerAvatar: some View {
        if let data = worker.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(AppTheme.accent.opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.body)
                        .foregroundColor(AppTheme.accent)
                )
        }
    }
}

#Preview {
    WorkerCardView(worker: LocalStorage.preview.workers[0])
        .padding()
}
